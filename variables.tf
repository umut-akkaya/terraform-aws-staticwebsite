variable "domainname" {
  description = "Static website domain name"
  type        = string
}

variable "extra_cnames" {
  description = "Extra CNAMEs for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "route53_hosted_zone_id" {
  description = "Route53 hosted zone id where dns records will be created"
  type        = string
  default     = null
}

variable "is_root" {
  description = "Controls whether domain name is root domain or a sub domain"
  type        = bool
  default     = false
}

variable "create_dns" {
  description = "Controls whether DNS resources should be created"
  type        = bool
  default     = false
}

variable "ssl_acm_certificate_arn" {
  description = "Cloudfront certificate which will be used for (us-east-1)"
  type        = string
  default     = null
}