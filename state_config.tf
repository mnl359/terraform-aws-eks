terraform { 
    backend "s3" {
        bucket          = "terraform-eks-01"
        key             = "terraform-eks-01/state"
        region          = "us-east-1"
        dynamodb_table  = "terraform-eks-01"
        encrypt         = true
    }
}
