# AWS STATIC WEBSITE TERRAFORM

## Introduction
This module allows you to create and host your static website on Amazon Web Services. It utilises AWS services **Cloudfront**, **Route53** and **S3** to store, distribute and share your website resources.

## Prerequisites

Before you are going to use this module first you need to setup your hostedzone and a certificate for your domain. The certificate must be created in AWS region **us-east-1** in order to comply with Cloudfront. Once you are created these resources you are ready to go. :rocket:

[!Architecture](./module.png?raw=true)

## Usage

There are 2 steps.
- Import hosted zone and certificate (If you want to add your domain to CF Distribution) as data sources.
- Create an instance from module

Example
```hcl
module "my-website" {
  source = "../aws-static-website-module"
  domainname = "test.umutakkaya.com"
  create_dns = true
  is_root = false
  route53_hosted_zone_id = data.aws_route53_zone.umutakkayacom.id
  ssl_acm_certificate_arn = data.aws_acm_certificate.issued.arn
}

data "aws_route53_zone" "umutakkayacom" {
  name         = "umutakkaya.com"
  private_zone = false
}

data "aws_acm_certificate" "issued" {
  provider = aws.us-east-1
  domain   = "test.umutakkaya.com"
  statuses = ["ISSUED"]
}
```

After creation of the necessary resources upload the static website file to s3 bucket. Then run the following command to tell Cloudfront for triggering new content delivery.

```shell
aws cloudfront create-invalidation --distribution <YOUR_DISTRIBUTION_ID>
```
# Terraform Module

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.website_cf_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_route53_record.cname_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.root_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.website_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.website_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.publicaccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.http-s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_iam_policy_document.acces_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_dns"></a> [create\_dns](#input\_create\_dns) | Controls whether DNS resources should be created | `bool` | `false` | no |
| <a name="input_domainname"></a> [domainname](#input\_domainname) | Static website domain name | `string` | n/a | yes |
| <a name="input_is_root"></a> [is\_root](#input\_is\_root) | Controls whether domain name is root domain or a sub domain | `bool` | `false` | no |
| <a name="input_route53_hosted_zone_id"></a> [route53\_hosted\_zone\_id](#input\_route53\_hosted\_zone\_id) | Route53 hosted zone id where dns records will be created | `string` | `null` | no |
| <a name="input_ssl_acm_certificate_arn"></a> [ssl\_acm\_certificate\_arn](#input\_ssl\_acm\_certificate\_arn) | Cloudfront certificate which will be used for (us-east-1) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cf_distribution_address"></a> [cf\_distribution\_address](#output\_cf\_distribution\_address) | n/a |
| <a name="output_s3_domain_name"></a> [s3\_domain\_name](#output\_s3\_domain\_name) | n/a |
| <a name="output_s3_endpoint_name"></a> [s3\_endpoint\_name](#output\_s3\_endpoint\_name) | n/a |

# Contributions

Just feel free for all contributions, ideas, PR's. 