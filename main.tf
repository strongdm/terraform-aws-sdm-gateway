provider "aws" {
  region = var.aws_region
}

provider "strongdm" {}

locals {
  default_tags = merge(
    var.tags,
    {
      Name        = var.name
      ManagedBy   = "terraform"
      Application = "strongdm"
    }
  )
}
