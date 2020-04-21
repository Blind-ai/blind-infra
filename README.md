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

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| availability\_zones | List of availability zones | `list(string)` | n/a | yes |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | `string` | `"-"` | no |
| enable\_autoscaling | Wether to install and setup autoscaling | `bool` | `true` | no |
| name | Solution name, e.g. 'wordpress' or 'platform' | `string` | n/a | yes |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| region | AWS Region where the ressource should be deployed | `string` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev' or 'testing' | `string` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| vpc\_cidr\_block | The VPC cidr block for the eks VPC | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->