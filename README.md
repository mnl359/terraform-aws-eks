# Wordpress Application Deployment using Terraform, Ansible and CircleCI to AWS

In the following notes I want to show you how to deploy Wordpress Application to AWS using Terraform, Ansible and CircleCI.

Long explanation on Medium. Coming soon...

## Used Technologies

- GitHub
- CircleCI
- AWS
- Terraform
- Ansible

## Basic Architecture

This is a 30,000 feet view of the architecture we are going to implement using this tutorial. 

![](images/basic-architecture.png)

1. A Cloud Architect design the infrastructure using Terraform and Ansible code and upload it to GitHub
2. GitHub communicates performed changes on `master` or `destroy`repositories to CircleCI
3. CircleCI get the source code from GitHub repository and prepare a virtual machine with all required tools (AWS CLI, Terraform and Ansible), establish comunication with AWS and deploy the infrastructure described on GitHub source code repository
4. AWS receive the instructions from Terraform and Ansible of how to deploy the corresponding resources

## AWS Architecture

![](images/architecture.png)

## GitHub

I assume that you're going to clone this respository, work in your workstation and with your own GitHub account. You need the following tools:

- Git
- Visual Studio Code (or any other IDE or Text Editor like Atom)

Once you have Git installed in your computer you can use the following command to clone this repository:

`git clone https://github.com/williammunozr/terraform-ansible-aws.git`

After that, remove the link to my repository:

`git remote remove origin`

And create your own GitHub repository. You need to follow this step to configure CircleCI.

## AWS configuration

It's good practice to manage the Terraform State and Lock on a centralized location. To accomplish this requirement we use DynamoDB and S3 Bucket.

- Create a S3 Bucket with versioning active
- Create a DynamoDB table with LockID as primary key

Adjust values on the following keys in state_config.tf file: 

| Line | Key Name       | Value                 | Description                                     |
| ---- | -------------- | --------------------- | ----------------------------------------------- |
| 3    | bucket         | terraform.hachiko.app | S3 Bucket name used to save the Terraform State |
| 7    | dynamodb_table | terraform-state-01    | DynamoDB table used to save the Terraform Lock  |

The full AWS configuration is outside of this tutorial. In short, we need an IAM user with access keys activated and with the following policy assigned:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "rds:*",
                "s3:*",
                "ec2:*",
                "dynamodb:*",
                "elasticloadbalancing:*",
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*"
        }
    ]
}
```

This policy gives the user all the permissions needed to work with this tutorial, but my recommendation is to give the least permissions as possible.

## Terraform Variables

Adjust default values on the following variables in variables.tf file.

| Line | Variable Name | Value | Description |
| --- | --- | --- | --- |
| 44 | vpc_name | terraform-ansible-01 | Name of the custom VPC |
| 49 | cidr_ab | development = "172.22" | Adjust the values accordingly to your needs. You must set values for: development, qa, staging and production |
| 97 | web_sg_name | web_sg_01 | Security Group to control the access from ALB to the Application Web Servers |
| 107 | alb_sg_name | alb_sg_01 | Security Group to control the access from Internet to the ALB |
| 117 | db_sg_name | db_sg | Security Group to control the access from Application Web Servers to RDS Database |
| 148 | key_name | terraform-ansible-01 | Name of SSH Key for accessing EC2 instances on AWS |
| 153 | ssh_public_key | terraform-ansible-aws.pub | Custom SSH Public Key for accessing EC2 instances |
| 160 | instance_name | App01 | Tag Name assigned to all EC2 instances. Used by Ansible to identify the EC2 instances and to configure them |
| 167 | rds_database_identifier | terraform-ansible-01 | RDS identifier to be used by Ansible to get the RDS Database needed data to deploy Wordpress |
| 177 | rds_database_name | terraformansible01 | RDS Database name |
| 193 | rds_subnet_group_name | db_private_subnet_01 | RDS Database private subnet |
| 225 | alb_name | terraform-ansible-alb-01 | Application Load Balancer name |

## Ansible Configuration

For Ansible, we are going to use `Dynamic Inventory `. With that in mind, set the `hosts` value in `ansible/app.yml` file to `tag_NAME_App01`, the value must correspond to the value you set in Terraform Variables for the entry `instance_name`, for this case correspond to `App01`. 

***Special Notice***

In reality, this value must correspond to a tag that you set in `public.tf` file on line `16` for the key-value `Name`, what happends here, it is that I configured both values to `var.instance_name`

The other value that we have to configure is  `--db-instance-identifier` on `.circleci/config.yml` file on line `80`. This must be the same value of Terraform Variables table `line 167`

## SSH Configuration

In order to access an AWS EC2 Instances we need to provide (create) a SSH Key to be used in the Terraform deployment process and this is also required by Ansible in the configuration management process. That's why we need to create a SSH Key, process that we're going to accomplish in this section.

In a Unix-like operating system the default location for the SSH keys is the .ssh directory within the current user's home directory. To create the a SSH key execute the following commands:

```
$ ssh-keygen -m PEM -t rsa -b 4096 -f ~/.ssh/terraform-ansible-aws
For simplicity, press enter to accept the default values.
```

Our last step in this section is to copy the public SSH key file to the root directory of the project and set the value of the variable named `private_key_file` in the `ansible.cfg` file to the full path of the private SSH key.

```
$ terraform-ansible-aws git:(master) cp -p ~/.ssh/terraform-ansible-aws.pub .
```

If you change the name of the SSH key (ansible_aws) for something different, you have to adjust the project accordingly.

## CircleCI Configuration

I assume you have an AWS account and that you know the basis of AWS administration and configuration. 

Coming soon...

# Side Notes

This project is not production ready, it has some weaknesses in its design, for example, you can see the RDS username and password in the code, what is a bad practice.

This project was intended to show how to work with Terraform, Ansible and CircleCI. 

