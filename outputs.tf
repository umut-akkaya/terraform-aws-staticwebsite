output "s3_endpoint_name" {
  value = aws_s3_bucket_website_configuration.http-s3.website_endpoint

}

output "s3_domain_name" {
  value = aws_s3_bucket_website_configuration.http-s3.website_domain

}

output "cf_distribution_address" {
  value = aws_cloudfront_distribution.website_cf_distribution.domain_name
}