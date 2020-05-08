# Wordpress Application Deployment using Terraform and CircleCI to AWS EKS

Following the instructions described in this project you will be able to deploy an AWS EKS cluster and also to deploy manually the Wordpress application.

## Requirements

- AWS Account with Access and Secret keys
- CircleCI Account
- GitHub Account
- Terraform

## AWS Account with Access and Secret keys

I assume that you have proficiency working with AWS. You must create a IAM User and assign it the needed permissions, you can find a JSON file in `aws-policy/eks-workshop-policy.json` with the permissions required to create a policy to follow this lab.

## GitHub

I assume that you're going to clone this respository, work in your workstation and with your own GitHub account. You need the following tools:

- Git
- Visual Studio Code (or any other IDE or Text Editor like Atom)

Once you have Git installed in your computer you can use the following command to clone this repository:

`git clone https://github.com/williammunozr/terraform-aws-eks.git`

After that, remove the link to my repository:

`git remote remove origin`

And create your own GitHub repository. You need it to hook CircleCI with your GitHub account.

## AWS configuration

It's good practice to manage the Terraform State and Lock on a centralized location. To accomplish this requirement we use DynamoDB and S3 Bucket.

- Create a S3 Bucket with versioning active
- Create a DynamoDB table with LockID as primary key

Adjust values on the following keys in state_config.tf file: 

| Line | Key Name       | Value                 | Description                                            |
| ---- | -------------- | --------------------- | ------------------------------------------------------ |
| 3    | bucket         | terraform.hachiko.app | S3 Bucket name used to save the Terraform State        |
| 5    | region         | us-east-1             | Region where you are going to deploy the AWS resources |
| 6    | dynamodb_table | terraform-state-01    | DynamoDB table used to save the Terraform Lock         |

## Terraform Variables

Adjust default values on the following variables in variables.tf file.

| Line | Variable Name | Value | Description |
| --- | --- | --- | --- |
| 5 | project_owner | Your Name | Project's owner |
| 10 | project_email | Owner Email | Project's owner email |
| 15 | project_name | Kubernetes | Project's name |
| 20 | is_project_terraformed | true | This allows us to identify if the AWS resource was deployed with Terraform |
| 46 | vpc_name | terraform-eks-01 | Name of the custom VPC |
| 52 | cidr_ab | development = "172.20" | Adjust the values accordingly to your needs. You must set values for: development, qa, staging and production |
| 90 | eks_cluster_name | eks-wordpress | AWS EKS cluster name |
| 96 | eks_instance_type | t2.medium | AWS EKS cluster worker nodes machine types |

## CircleCI Configuration

I assume you have an AWS account and that you know the basis of AWS administration and configuration. 

Coming soon... 

