terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Created once by hand (see README): versioned, private, us-east-1.
  backend "s3" {
    bucket = "leonardgrazian-terraform-state"
    key    = "personal-site/terraform.tfstate"
    region = "us-east-1"
  }
}

# Everything lives in us-east-1: CloudFront requires its ACM certificate there.
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project = "personal-site"
    }
  }
}
