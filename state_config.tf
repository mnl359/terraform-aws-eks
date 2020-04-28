terraform { 
    backend "s3" {
        bucket          = "terraform.hachiko.app"
        #bucket          = "terraform-ansible-01"
        key             = "terraform-circleci-00/state"
        region          = "us-east-1"
        dynamodb_table  = "terraform-state-01"
        encrypt         = true
    }
}
