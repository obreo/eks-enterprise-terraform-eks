variable "ssh_public_key" {
  type = string
  description = "The public SSH key to be used for the EKS worker nodes."
}


variable "terraform_remote_outputs" {
  type = object({
    vpc_s3_bucket        = string
    vpc_s3_key           = string
    vpc_s3_key_region    = string
  })
  description = "Remote state configuration for the VPC module."
}

variable "metadata" {
  type = object({
    name        = string
    environment = string
    eks_version = string
    region      = string
  })
  default = {
    region = "us-east-1"
    environment = ""
    eks_version = ""
    name = ""
  }
}

variable "cluster_settings" {
    type = object({
      ip_family = string
      allowed_cidrs_to_access_cluster_publicly = optional(list(string), [])
      custom_group_access_policies = optional(list(string), [])
    })
}

variable "hostname" {
  type = string
}