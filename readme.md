![blind banner](.github/banner.png)

---

![terraform version](https://img.shields.io/badge/terraform-%3E%3D%200.12-blue)

## Blind - Infra

This mono repository setup all the infrastructure that is needed today by Blind project.

# Documentation

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | ~> 2.0 |
| null | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| null | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| availability\_zones | List of availability zones | `list(string)` | n/a | yes |
| cluster\_vpc\_cidr\_block | The VPC cidr block for the eks VPC | `string` | n/a | yes |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | `string` | `"-"` | no |
| name | Solution name, e.g. 'wordpress' or 'platform' | `string` | n/a | yes |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| region | AWS Region where the ressource should be deployed | `string` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev' or 'testing' | `string` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_label\_context | The context used to set the different tags needed by EKS. This should be used to create the EKS cluster. |
| vpc\_cidr | An object that contains the cidr block for each vpc |
| vpc\_default\_security\_group\_id | An object that contains the default security group id for each vpc |
| vpc\_id | An object that contains the id for each vpc |
| vpc\_private\_subnet\_cidrs | An object that contains the private subnets cidr for each vpc |
| vpc\_private\_subnet\_ids | An object that contains the private subnets ids for each vpc |
| vpc\_public\_subnet\_cidrs | An object that contains the public subnets cidr for each vpc |
| vpc\_public\_subnet\_ids | An object that contains the public subnets ids for each vpc |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->