    bucket       = "abra-terraform-states"
    key          = "kubernetes/eks/staging/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

    # terraform init -backend-config=environments/staging/backend.tfvars