module "bastion-oregon" {
  source = "../../modules/bastion"
  providers = {
    aws.region = aws.us-west-2
  }
  region     = "us-west-2"
  ec2_name   = "kempy-fivetran-bastion"
  vpc_id     = data.aws_vpc.vpc_oregon.id
  subnet_ids = tolist(data.aws_subnets.public_oregon.ids)
}

resource "local_file" "write-key-oregon" {
  content  = module.bastion-oregon.private_key
  filename = "${path.module}/bastion-key-oregon.pem"
}

output "connect" {
  value = <<-EOF
    chmod 400 bastion-key-oregon.pem
    # Oregon
    ssh -i bastion-key-oregon.pem ec2-user@${module.bastion-oregon.public_ip}
  EOF
}


resource "random_string" "random" {
  length  = 64
  special = false
}

resource "aws_ssm_parameter" "dbpwd" {
  provider  = aws.us-west-2
  name      = "/kempy/dbpwd"
  value     = random_string.random.result
  type      = "String"
  overwrite = true
}

module "rds-oregon" {
  source = "../../modules/rds"
  providers = {
    aws.region = aws.us-west-2
  }
  name                  = "kempy-psql"
  ssm_pwd               = aws_ssm_parameter.dbpwd.name
  region                = "us-west-2"
  vpc_id                = data.aws_vpc.vpc_oregon.id
  subnet_ids            = tolist(data.aws_subnets.private_oregon.ids)
  ec2_security_group_id = module.bastion-oregon.security_group
  depends_on = [
    aws_ssm_parameter.dbpwd
  ]
}
