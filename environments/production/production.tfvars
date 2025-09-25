# Generated SSH public key for the EKS cluster
#ssh_key = ""

# Remote state configuration for the VPC module
terraform_remote_outputs = {
    vpc_s3_bucket        = "my-terraform-state-bucket"
    vpc_s3_key           = "kubernetes/vpc/production.tfstate"
    vpc_s3_key_region    = "us-east-1"
}

metadata = {
    name        = "EKS-Production"
    environment = "production"
    eks_version = "1.32"
    region      = "us-east-1"
}

cluster_settings = {
    ip_family = "ipv6"
    allowed_cidrs_to_access_cluster_publicly = ["0.0.0.0/0"]
    custom_group_access_policies = ["eks:ListClusters","eks:DescribeCluster"]
}

