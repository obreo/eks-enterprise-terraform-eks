# Collect Info outputs from VPC module:
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.terraform_remote_outputs.vpc_s3_bucket
    key    = var.terraform_remote_outputs.vpc_s3_key
    region = var.terraform_remote_outputs.vpc_s3_key_region
  }
}

# Setup the EKS cluster using the VPC module outputs
module "eks" {
  source = "git::https://github.com/obreo/iac-modules.git//terraform/eks?ref=main"
  metadata = {
    name        = var.metadata.name
    environment = var.metadata.environment
    eks_version = var.metadata.eks_version
    region      = var.metadata.region
  }

  cluster_settings = {
    cluster_subnet_ids                       = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks                    
    security_group_ids                       = [data.terraform_remote_state.vpc.outputs.security_group_ids["eks_ipv4"], data.terraform_remote_state.vpc.outputs.security_group_ids["eks_ipv6"]]
    allowed_cidrs_to_access_cluster_publicly = var.cluster_settings.allowed_cidrs_to_access_cluster_publicly # Optional, set default to an empty list. 
    enable_endpoint_public_access            = true
    enable_endpoint_private_access           = true
    create_eks_admin_access_iam_group        = true
    create_eks_custom_access_iam_group       = var.cluster_settings.custom_group_access_policies # Default to an empty list, else fill with EKS policies names. e.g "eks:listClusters"
    ip_family                                = var.cluster_settings.ip_family

    enable_logging = {
      audit             = true
      authenticator     = true
      retention_in_days = 1
    }

    addons = {
      vpc_cni                         = true
      eks_pod_identity_agent          = true
      amazon_cloudwatch_observability = true
      aws_mountpoint_s3_csi_driver = {
          enable        = true # Defaults to false
      }
    }
  }

  node_settings = {
    cluster_name          = module.eks.cluster_name
    workernode_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
    #remote_access = {
    #  enable       = true
    #  ssh_key_name = aws_key_pair.ssh.key_name
    #}
    labels = {
      "environment" = "${var.metadata.environment}",
    }
    capacity_config = {
      instance_types = ["t3.medium"]
      disk_size      = 30 # Optional, default to 20GB
    }
    scaling_config = {
      desired         = 1 # Optional, default to 1
      max_size        = 2 # Optional, default to 1
      min_size        = 1 # Optional, default to 1
      max_unavailable = 1 # Optional, default to 1
    }
  }
}

module "eks_bootstrap" {
  source = "git::https://github.com/obreo/iac-modules.git//terraform/eks_bootstrap?ref=main"

  integrations = {
    cluster_name = var.metadata.name
    create_ecr_registry = {
      name = lower(var.metadata.name)
    }

    aws_ebs_csi_driver              = {}

    aws_mountpoint_s3_csi_driver = {
      name            = lower(var.metadata.name)
      create_vpc_endpoint = {
        vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
        bucket_region = var.metadata.region
      }
    }
  }

  plugins = {
    cluster_autoscaler  = {}
    metrics_server      = {}
    cert_manager        = {}
    argo_cd             = {
      values = [
        yamlencode(
          {
            global = {
              dualStack = {
                ipFamilies = ["IPv6"]
              }
            }
          }
        )
      ]
    }
    nginx_controller    = {
      nginx-external = {
        alb_config = {
          alb_family_type         = "dualstack"
        }

        values = [
          yamlencode(
            {
              controller = {
                service = {
                  ipFamilies = ["IPv6"]
                }
              }
            }
          )
        ]
      }
    }
    aws_alb_controller = {
      vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
      eks_cluster_name = var.metadata.name
      region = var.metadata.region
    }
    external_secrets = {
      values = [
        yamlencode(
          {
            service = {
              ipFamilies = ["IPv6"]
            }
          }
        )
      ]
    }
    loki = {}
    prometheus = {}
  }
  depends_on = [ module.eks ]
}


