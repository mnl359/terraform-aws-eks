/* Database Servers */

resource "aws_db_subnet_group" "private_subnets" {
    name                    = var.rds_subnet_group_name
    subnet_ids              = module.vpc.private_subnets

    tags = {
        Name                = var.rds_subnet_group_name
        Terraform           = var.is_project_terraformed
        Environment         = var.environment
        Owner               = var.project_owner
        Email               = var.project_email
        Project_Name        = var.project_name
    }
}

resource "aws_db_instance" "default" {
    identifier              = var.rds_database_identifier
    allocated_storage       = var.rds_allocated_storage
    storage_type            = var.rds_storage_type
    engine                  = var.rds_engine
    engine_version          = var.rds_engine_version
    instance_class          = var.rds_instance_class
    name                    = var.rds_database_name
    username                = var.rds_database_username
    password                = var.rds_database_password
    parameter_group_name    = var.rds_parameter_group_name
    availability_zone       = module.vpc.azs[0]
    vpc_security_group_ids  = [module.db_sg.this_security_group_id]
    db_subnet_group_name    = aws_db_subnet_group.private_subnets.name
    skip_final_snapshot     = "true"

    tags = {
        Name                = var.rds_database_name
        Terraform           = var.is_project_terraformed
        Environment         = var.environment
        Owner               = var.project_owner
        Email               = var.project_email
        Project_Name        = var.project_name
    }
}
