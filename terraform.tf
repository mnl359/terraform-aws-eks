# Terraform configuration
terraform {
    backend "s3" {
        bucket  = "tfstate-hachiko-app"
        key     = "terraform.tfstate"
        region  = "us-east-1"
    }
}