data "aws_caller_identity" "current" {}

module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source = "./modules/ec2"

  iam_instance_profile_name = module.iam.instance_profile_name

  depends_on = [module.iam]
}

module "github_oidc" {
  source = "./modules/github-oidc"
  aws_account_id = data.aws_caller_identity.current.account_id
}
