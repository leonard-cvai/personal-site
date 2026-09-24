variable "domain" {
  description = "Apex domain; its Route 53 hosted zone must already exist."
  type        = string
  default     = "leonardgrazian.com"
}

variable "bucket_name" {
  description = "Private S3 bucket holding the built site."
  type        = string
  default     = "leonardgrazian-com-site"
}

variable "github_repo" {
  description = "owner/repo allowed to deploy via GitHub Actions OIDC."
  type        = string
  default     = "leonard-cvai/personal-site"
}
