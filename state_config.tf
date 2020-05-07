terraform { 
    backend "s3" {
        bucket          = "terraform.hachiko.app"
        key             = "terraform-eks-00/state"
        region          = "us-east-1"
        dynamodb_table  = "terraform-state-01"
        encrypt         = true
    }
}
