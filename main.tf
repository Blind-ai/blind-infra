# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURE VARIOUS PROVIDERS
# ----------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = var.region
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE VPC AND THE SUBNETS FOR THE EKS CLUSTER
# ----------------------------------------------------------------------------------------------------------------------
locals {
  eks_common_tags = merge(var.tags, map("kubernetes.io/cluster/${module.cluster_label.id}", "shared"))
}

module "cluster_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = ["cluster", "eks"]
}

module "cluster_vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = ["cluster", "vpc"]
  cidr_block = var.vpc_cidr_block
  tags       = local.eks_common_tags
}

module "cluster_subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.19.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = ["cluster", "subnets"]
  vpc_id               = module.cluster_vpc.vpc_id
  igw_id               = module.cluster_vpc.igw_id
  cidr_block           = module.cluster_vpc.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  tags                            = local.eks_common_tags
  private_subnets_additional_tags = map("kubernetes.io/role/elb", 1)
  public_subnets_additional_tags  = map("kubernetes.io/role/internal-elb", 1)
}

# ----------------------------------------------------------------------------------------------------------------------
# PROVIDER RELATED TO KUBERNETES
# ----------------------------------------------------------------------------------------------------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY THE EKS WITH THE GIVEN NODE GROUPS
# ----------------------------------------------------------------------------------------------------------------------
locals {
  eks_workers_tags = {
    "k8s.io/cluster-autoscaler/${module.cluster_label.id}" = "owned",
    "k8s.io/cluster-autoscaler/enabled"                    = "enabled"
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = module.cluster_label.id

  subnets = concat(
    module.cluster_subnets.public_subnet_ids,
    module.cluster_subnets.private_subnet_ids
  )

  workers_group_defaults = {
    subnets = module.cluster_subnets.private_subnet_ids
  }

  vpc_id      = module.cluster_vpc.vpc_id
  enable_irsa = true

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 10
  }

  node_groups = {

    default = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 2

      instance_type = "t2.micro"

      k8s_labels = {
        tier = "service-runtime"
      }

      additional_tags = local.eks_workers_tags
    }

    tensorflow_gpu = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      ami_type      = "AL2_x86_64_GPU"
      instance_type = "p3.2xlarge"

      k8s_labels = {
        tier = "ai-runtime"
      }

      additional_tags = local.eks_workers_tags
    }

  }

  tags = module.cluster_label.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# AUTO SCALING POLICIES AND SERVICE ACCOUNTS
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "worker_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${module.cluster_label.id}"
  description = "EKS worker node autoscaling policy for cluster ${module.cluster_label.id}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.cluster_label.id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "worker_ecs_access" {
  policy_arn = aws_iam_policy.worker_ecs_access.arn
  role       = module.eks.worker_iam_role_name
}

resource "aws_iam_policy" "worker_ecs_access" {
  name_prefix = "eks-worker-ecr-${module.cluster_label.id}"
  description = "EKS worker node ecr access policy for cluster ${module.cluster_label.id}"
  policy      = data.aws_iam_policy_document.worker_ecs_access.json
}

data "aws_iam_policy_document" "worker_ecs_access" {
  statement {
    sid    = "eksEcrAll"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# WAIT FOR THE CLUSTER TO BE READY AND INSTALL THE AUTOSCALER HELM CHART INSIDE
# ----------------------------------------------------------------------------------------------------------------------
data "null_data_source" "wait_for_nodes" {
  inputs = {
    cluster_id  = module.eks.cluster_id
    node_groups = join("|", keys(module.eks.node_groups))
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "helm_repository" "stable" {
  count = var.enable_autoscaling ? 1 : 0
  name  = "stable"
  url   = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "autoscaler" {
  depends_on = [data.null_data_source.wait_for_nodes]
  count      = var.enable_autoscaling ? 1 : 0
  name       = "autoscaler"
  namespace  = "kube-system"
  repository = data.helm_repository.stable.0.metadata[0].url
  chart      = "cluster-autoscaler"
  version    = "7.1.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = data.null_data_source.wait_for_nodes.outputs.cluster_id
  }

  set {
    name  = "autoDiscovery.enabled"
    value = true
  }

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.create"
    value = true
  }
}

resource "helm_release" "metrics-server" {
  depends_on = [data.null_data_source.wait_for_nodes]
  name       = "metrics-server"
  chart      = "stable/metrics-server"
  namespace  = "kube-system"
}
