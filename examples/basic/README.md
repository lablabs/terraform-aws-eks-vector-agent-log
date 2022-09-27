# Basic example

The code in this example shows how to use the module with basic configuration and minimal set of other resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.19.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.11.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.17.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | cloudposse/eks-cluster/aws | 0.43.2 |
| <a name="module_eks_node_group"></a> [eks\_node\_group](#module\_eks\_node\_group) | cloudposse/eks-node-group/aws | 0.25.0 |
| <a name="module_vector_log_cloudwatch_argo_helm"></a> [vector\_log\_cloudwatch\_argo\_helm](#module\_vector\_log\_cloudwatch\_argo\_helm) | ../../ | n/a |
| <a name="module_vector_log_cloudwatch_argo_manifests"></a> [vector\_log\_cloudwatch\_argo\_manifests](#module\_vector\_log\_cloudwatch\_argo\_manifests) | ../../ | n/a |
| <a name="module_vector_log_cloudwatch_helm"></a> [vector\_log\_cloudwatch\_helm](#module\_vector\_log\_cloudwatch\_helm) | ../../ | n/a |
| <a name="module_vector_log_loki"></a> [vector\_log\_loki](#module\_vector\_log\_loki) | ../../ | n/a |
| <a name="module_vector_log_opensearch"></a> [vector\_log\_opensearch](#module\_vector\_log\_opensearch) | ../../ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
