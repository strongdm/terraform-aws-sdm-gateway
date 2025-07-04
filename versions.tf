terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    sdm = {
      source  = "strongdm/sdm"
      version = ">=3.3.0"
    }
  }
}
