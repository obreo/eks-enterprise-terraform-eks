# EKS Enterprise - IaC - EKS

This infrastructure deploys a **scalable, cost-optimized, and easy-to-deploy EKS cluster** in AWS using a custom Terraform module that follows best practices.

The cluster is **IPv6-only within a dual-stack VPC** to address IPv4 address exhaustion for pods. This allows launching **smaller EC2 instances with more pods**, scaling out nodes based on CPU/memory usage rather than being limited by [ENI max pods per instance](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/misc/eni-max-pods.txt).

The deployment balances **security best practices** and ease of deployment:

* The cluster resides in **private subnets**, with NAT gateways for IPv4 connections to the EKS API and AWS services.
* **Egress-only gateways** provide IPv6 outbound connectivity for pods.

### Automated Features (via IRSA access)

1. S3 Gateway Endpoint
2. EBS CSI Driver
3. Cluster Autoscaler
4. Metrics Server
5. Cert Manager
6. ArgoCD
7. Nginx Controller (IPv6)
8. ALB Controller (Dual-stack)
9. External Secrets Operator
10. ECR repositories

Deployment uses **two custom Terraform modules**:

* One for EKS cluster creation.
* One for EKS Helm plugins.

For more info, see the [repository](https://github.com/obreo/iac-modules.git).

---

# GitOps Workflow

This module integrates with **GitHub Actions** using **OpenID Connect (OIDC)** to authenticate with AWS. The workflow:

1. Clones the source repository.
2. Retrieves updated Terraform modules.
3. Plans and applies the deployment per environment.

* **Staging:** replicates production.
* **Development:** verifies the plan before promotion.

---

# Prerequisites

* Terraform
* Configured AWS CLI with permissions for VPC resources.
* Private S3 bucket with `PutObject` and `GetObject` permissions for Terraform state.

---

# How to Use Template

1. Clone the main branch.
2. Configure `environments/ENVIRONMENT/backend.tfvars` for the S3 backend.
3. Configure `environments/ENVIRONMENT/ENVIRONMENT.tfvars` with environment variables.

By default, **only production and staging** are deployed. Development uses staging state for verification only.

4. Deploy the infrastructure:

```bash
terraform init -backend-file "environments/ENV/backend.tfvars"
terraform plan -var-file "environments/ENV/ENV.tfvars" -out=tfplan
terraform apply "tfplan"
```

For further configuration, refer to the [EKS module](https://github.com/obreo/iac-modules.git/terraform/eks?ref=main) and [EKS_Bootstrap module](https://github.com/obreo/iac-modules.git/terraform/eks_bootstrap?ref=main).
