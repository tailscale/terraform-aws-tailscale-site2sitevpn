module "lbr-vpc-west" {
  providers = {
    aws = aws.west
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name               = "lbr-site2site-vpc-west"
  cidr               = local.vpc_cidr_west
  enable_nat_gateway = true

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = local.vpc_private_subnets_west
  public_subnets  = local.vpc_public_subnets_west

}

module "lbr-site2site-west" {
  source = "../../"
  providers = {
    aws = aws.west
  }
  remote_addresses    = [local.vpc_cidr_east]
  route_table_ids     = concat(module.lbr-vpc-west.private_route_table_ids, module.lbr-vpc-west.public_route_table_ids)
  vpc_id              = module.lbr-vpc-west.vpc_id
  name                = "lbr-site2site-west"
  subnet_id           = module.lbr-vpc-west.public_subnets[0]
  advertise_addresses = [local.vpc_cidr_west]
  tailscale_auth_key  = var.tailscale_auth_key
  depends_on          = [module.lbr-vpc-west]
}

module "lbr-s2sclient-west" {
  source = "./client"
  providers = {
    aws = aws.west
  }
  name            = "lbr-s2sclient-west"
  subnet_id       = module.lbr-vpc-west.private_subnets[1]
  vpc_id          = module.lbr-vpc-west.vpc_id
  ssh_key_content = var.ssh_key_content
  depends_on      = [module.lbr-vpc-west]
}
