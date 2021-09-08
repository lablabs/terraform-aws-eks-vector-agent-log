# AWS EKS Ingress Nginx Controller Terraform module

[![Labyrinth Labs logo](ll-logo.png)](https://www.lablabs.io)

We help companies build, run, deploy and scale software and infrastructure by embracing the right technologies and principles. Check out our website at https://lablabs.io/

---

![Terraform validation](https://github.com/lablabs/terraform-aws-eks-vector-agent-log/workflows/Terraform%20validation/badge.svg?branch=master)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-success?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

## Description

A terraform module to deploy an Vector as Agent .

## Related Projects

Check out these related projects.

- [terraform-aws-eks-external-dns](https://github.com/lablabs/terraform-aws-eks-external-dns)
- [terraform-aws-eks-calico](https://github.com/lablabs/terraform-aws-eks-calico)
- [terraform-aws-eks-cluster-autoscaler](https://github.com/lablabs/terraform-aws-eks-cluster-autoscaler)
- [terraform-aws-eks-alb-ingress](https://github.com/lablabs/terraform-aws-eks-alb-ingress)
- [terraform-aws-eks-metrics-server](https://github.com/lablabs/terraform-aws-eks-metrics-server)
- [terraform-aws-eks-prometheus-node-exporter](https://github.com/lablabs/terraform-aws-eks-prometheus-node-exporter)
- [terraform-aws-eks-kube-state-metrics](https://github.com/lablabs/terraform-aws-eks-kube-state-metrics)
- [terraform-aws-eks-node-problem-detector](https://github.com/lablabs/terraform-aws-eks-node-problem-detector)


## Examples

See [Basic example](examples/basic/README.md) for further information.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 2.0 |
| helm | >= 1.0 |
| utils | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |
| helm | >= 1.0 |
| kubernetes | n/a |
| utils | >= 0.12.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |
| [kubernetes_manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) |
| [utils_deep_merge_yaml](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argo\_destionation\_server | Destination server for ArgoCD Application | `string` | `"https://kubernetes.default.svc"` | no |
| argo\_info | ArgoCD info manifest parameter | `list` | <pre>[<br>  {<br>    "name": "terraform",<br>    "value": "true"<br>  }<br>]</pre> | no |
| argo\_namespace | Namespace to deploy ArgoCD application CRD to | `string` | `"argo"` | no |
| argo\_project | ArgoCD Application project | `string` | `"default"` | no |
| argo\_sync\_policy | ArgoCD syncPolicy manifest parameter | `map` | `{}` | no |
| argocd\_application | If set to true, the module will be deployed as ArgoCD application, otherwise it will be deployed as a Helm release | `bool` | `false` | no |
| cloudwatch\_containers\_tags | A map of tags to assign to the resource. | `map(any)` | `{}` | no |
| cloudwatch\_enabled | Variable indicating whether default cloudwatch group with iam role is created and configured as vector sink | `bool` | `false` | no |
| cloudwatch\_group\_containers\_kms\_key\_id | The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested. | `string` | `""` | no |
| cloudwatch\_group\_containers\_retention | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `14` | no |
| cloudwatch\_group\_name\_prefix | The name of the log group | `string` | `"/aws/eks"` | no |
| cloudwatch\_group\_nodes\_kms\_key\_id | The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested. | `string` | `""` | no |
| cloudwatch\_group\_nodes\_retention | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `14` | no |
| cloudwatch\_nodes\_tags | A map of tags to assign to the resource. | `map(any)` | `{}` | no |
| cloudwatch\_role\_name\_prefix | The role name prefix for vector cloudwatch ingest | `string` | `"eks-irsa"` | no |
| cluster\_identity\_oidc\_issuer | The OIDC Identity issuer for the cluster | `string` | n/a | yes |
| cluster\_identity\_oidc\_issuer\_arn | The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account | `string` | n/a | yes |
| cluster\_name | The name of the cluster | `string` | n/a | yes |
| enabled | Variable indicating whether deployment is enabled | `bool` | `true` | no |
| helm\_chart\_name | Helm chart name to be installed | `string` | `"vector-agent"` | no |
| helm\_chart\_version | Version of the Helm chart | `string` | `"0.15.1"` | no |
| helm\_create\_namespace | Whether to create k8s namespace with name defined by `k8s_namespace` | `bool` | `true` | no |
| helm\_release\_name | Helm release name | `string` | `"vector-agent"` | no |
| helm\_repo\_url | Helm repository | `string` | `"https://packages.timber.io/helm/latest"` | no |
| k8s\_namespace | The K8s namespace in which the vector agent will be installed | `string` | `"kube-system"` | no |
| settings | Additional settings which will be passed to the Helm chart values to be merged with the values yaml, see https://artifacthub.io/packages/helm/vector/vector-agent | `map(any)` | `{}` | no |
| values | Additional values. Values will be merged, in order, as Helm does with multiple -f options | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| helm\_release\_attributes | Helm release attributes |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing and reporting issues

Feel free to create an issue in this repository if you have questions, suggestions or feature requests.

### Validation, linters and pull-requests

We want to provide high quality code and modules. For this reason we are using
several [pre-commit hooks](.pre-commit-config.yaml) and
[GitHub Actions workflow](.github/workflows/main.yml). A pull-request to the
master branch will trigger these validations and lints automatically. Please
check your code before you will create pull-requests. See
[pre-commit documentation](https://pre-commit.com/) and
[GitHub Actions documentation](https://docs.github.com/en/actions) for further
details.


## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
