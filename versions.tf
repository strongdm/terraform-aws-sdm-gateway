terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    strongdm = {
      source  = "strongdm/strongdm"
      version = ">= 1.0.0"
    }
  }
}
