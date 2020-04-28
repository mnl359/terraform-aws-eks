/* Web Servers */

resource "aws_instance" "webserver" {
    depends_on                  = [aws_db_instance.default]
    count                       = var.number_of_instances
    ami                         = lookup(var.aws_amis, lookup(var.region, var.environment))
    availability_zone           = module.vpc.azs[count.index]
    instance_type               = var.ec2_machine_type
    key_name                    = aws_key_pair.admin_key.key_name
    vpc_security_group_ids      = [module.web_sg.this_security_group_id]
    subnet_id                   = module.vpc.public_subnets[count.index]
    associate_public_ip_address = true
    source_dest_check           = false

    tags = {
        Name                    = var.instance_name
        Terraform               = var.is_project_terraformed
        Environment             = var.environment
        Owner                   = var.project_owner
        Email                   = var.project_email
        Project_Name            = var.project_name
    }

    # provisioner "local-exec" {
    #     command = "aws ec2 wait instance-status-ok --instance-ids ${self.id} --profile default && ansible-playbook -i ansible/ec2.py ansible/app.yml --user ec2-user -e db_endpoint=${aws_db_instance.default.address}"
    # }
}

resource "aws_eip" "webserver" {
    count       = var.number_of_instances
    instance    = aws_instance.webserver[count.index].id
    vpc         = true
}

resource "aws_key_pair" "admin_key" {
    key_name    = var.key_name
    public_key  = file(var.ssh_public_key)
}