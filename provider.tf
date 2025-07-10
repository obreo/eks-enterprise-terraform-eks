terraform {
  backend "s3" {
      /* Multiple environments will be used, each with .tfvars file.
      bucket       = "abra-terraform-states"
      key          = "kubernetes/terraform.tfstate"
      region       = "us-east-1"
      encrypt      = true
      use_lockfile = true
      */
  }
  required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
      }

      helm = {
        source  = "hashicorp/helm"
        version = ">= 3.0.2"
      }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = var.metadata.region
  #shared_config_files      = ["~/.aws/config"]
  #shared_credentials_files = ["~/.aws/credentials"]
  #profile                  = "default"
}
##########################################################################

provider "helm" {
  kubernetes = {
    host                   = module.eks.aws_eks_cluster_data
    token                  = module.eks.aws_eks_cluster_auth
    cluster_ca_certificate = base64decode(module.eks.aws_eks_cluster_certificate_data)
    #config_path = "~/.kube/config"
  }

}

#######################################################################
provider "kubernetes" {
  host                   = module.eks.aws_eks_cluster_data
  token                  = module.eks.aws_eks_cluster_auth
  cluster_ca_certificate = base64decode(module.eks.aws_eks_cluster_certificate_data)
  #config_path = "~/.kube/config"
}