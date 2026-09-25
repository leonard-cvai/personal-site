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

# GitHub's OIDC `sub` claim qualifies the owner and repo with their immutable numeric IDs
# (repo:owner@<id>/repo@<id>:...). Look them up with: curl https://api.github.com/repos/<owner/repo>
variable "github_owner_id" {
  description = "Numeric GitHub ID of the repo owner."
  type        = number
  default     = 13444386
}

variable "github_repo_id" {
  description = "Numeric GitHub ID of var.github_repo."
  type        = number
  default     = 1385650412
}
