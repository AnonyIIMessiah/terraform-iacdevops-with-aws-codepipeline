module "ec2_public" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"
  name = "${var.environment}-BastionHost"
  ami           = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  key_name      = var.instance_keypair
  subnet_id = module.vpc.public_subnets[0]
  user_data = file("${path.module}/jumpbox-install.sh")
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  tags                   = local.common_tags
}

