module "lbr-vpc-east" {
  providers = {
    aws = aws.east
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name               = "lbr-site2site-vpc-east"
  cidr               = local.vpc_cidr_east
  enable_nat_gateway = true

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = local.vpc_private_subnets_east
  public_subnets  = local.vpc_public_subnets_east

}

# tflint-ignore: terraform_module_version
module "lbr-site2site-east" {
  source = "../../"
  providers = {
    aws = aws.east
  }
  remote_addresses    = [local.vpc_cidr_west]
  route_table_ids     = concat(module.lbr-vpc-east.private_route_table_ids, module.lbr-vpc-east.public_route_table_ids)
  vpc_id              = module.lbr-vpc-east.vpc_id
  name                = "lbr-site2site-east"
  subnet_id           = module.lbr-vpc-east.public_subnets[0]
  advertise_addresses = [local.vpc_cidr_east]
  tailscale_auth_key  = var.tailscale_auth_key
  depends_on          = [module.lbr-vpc-east]
}


module "lbr-s2sclient-east" {
  source = "./client"
  providers = {
    aws = aws.east
  }
  name            = "lbr-s2sclient-east"
  subnet_id       = module.lbr-vpc-east.private_subnets[1]
  vpc_id          = module.lbr-vpc-east.vpc_id
  ssh_key_content = var.ssh_key_content

  depends_on = [module.lbr-vpc-east]
}
