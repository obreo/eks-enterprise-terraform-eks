    bucket       = "BUTCKET_NAME"
    key          = "kubernetes/vpc/staging.tfstate"
    region       = "REGION"
    encrypt      = true
    use_lockfile = true

    # Command to initialize Terraform with this backend configuration:
    # terraform init -backend-config=environments/staging/backend.tfvars