    bucket       = "BUTCKET_NAME"
    key          = "kubernetes/vpc/production.tfstate"
    region       = "REGION"
    encrypt      = true
    use_lockfile = true

    # Command to initialize Terraform with this backend configuration:
    # terraform init -backend-config=environments/production/backend.tfvars