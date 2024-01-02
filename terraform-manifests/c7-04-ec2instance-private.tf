module "ec2_private" {
  depends_on = [module.vpc] 
  source     = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"
  name          = "${var.environment}-frontend"
  ami           = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  key_name      = var.instance_keypair
  user_data = templatefile("app.tmpl", { rds_db_endpoint = module.rdsdb.db_instance_address })
  tags      = local.common_tags
  for_each               = toset(["0", "1"])
  subnet_id              = element(module.vpc.private_subnets, tonumber(each.key))
  vpc_security_group_ids = [module.private_sg.security_group_id]
}


