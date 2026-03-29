# aws-gov-infra — Full Platform Stack on top of coder4gov

Internal GitOps repo that composes on top of
[coder4gov](https://github.com/coder/coder4gov) via `terraform_remote_state`,
adding the full demo platform stack.

## Relationship to coder4gov

`coder4gov` is standalone — customers fork it and deploy Coder. This repo adds
everything else needed for the full gov-demo environment. No submodules; the
two repos are connected via Terraform remote state and FluxCD.

### Deployment Sequence

```text
Step 1: coder4gov — terraform apply (layers 0 → 4)
          │
          │ terraform_remote_state
          ▼
Step 2: aws-gov-infra — terraform apply (data + gitlab + platform)
          │
          ▼
Step 3: FluxCD reconciles both repos' cluster manifests
```

## What This Deploys

| Component | Where | Purpose |
|---|---|---|
| GitLab CE + Docker Runner | EC2 (m7a.2xlarge) | Git source-of-truth, CI/CD |
| Keycloak | EKS | Central SSO (OIDC) for Coder, GitLab, Grafana |
| LiteLLM | EKS | AI gateway → Bedrock (Claude), OpenAI, Gemini |
| coder-observability | EKS | Prometheus + Grafana + Loki |
| Istio | EKS | mTLS on all east-west traffic |
| WAF | AWS | WebACL for all ALBs |
| FluxCD | EKS | GitOps reconciliation |
| OpenSearch | AWS | SIEM (CloudTrail, VPC Flow Logs) |
| SES | AWS | Email notifications |
| S3 | AWS | GitLab backups, Loki logs |

## Repo Structure

```text
├── docs/
│   └── BEDROCK_SETUP.md        # Enable Claude models in Bedrock
├── images/
│   └── build.gitlab-ci.yml     # GitLab CI → ECR pipeline
├── clusters/
│   └── gov-demo/               # FluxCD manifests (Day 2 — GitOps)
│       ├── infrastructure/     # Namespaces, HelmRepos, ExternalSecrets
│       └── apps/               # Keycloak, LiteLLM, monitoring
└── infra/
    └── terraform/
        ├── data/               # OpenSearch, SES, S3 (consumes coder4gov L1+L2)
        ├── gitlab/             # GitLab CE EC2 + ALB (consumes coder4gov L1+L2)
        └── platform/           # Istio, WAF, FluxCD (consumes coder4gov L3+L4)
```

## Integration Contract

This repo consumes the following outputs from coder4gov via `terraform_remote_state`:

| Output | Source Layer | Used By |
|---|---|---|
| `vpc_id`, `private_subnet_ids`, `public_subnet_ids` | 1-network | GitLab SGs, ALB, OpenSearch |
| `route53_zone_id` | 1-network | GitLab DNS, Keycloak DNS |
| `eks_cluster_name`, `eks_cluster_endpoint`, `eks_oidc_provider_arn` | 3-eks | Istio, FluxCD, Kyverno |
| `rds_endpoint`, `rds_port` | 2-data | Additional databases (litellm, keycloak) |
| `kms_key_arn` | 2-data | Encryption for GitLab EBS, S3, secrets |
| `karpenter_node_role_name` | 4-bootstrap | Podman EC2NodeClass |
| `ecr_repo_urls` | 2-data | Image references in Flux manifests |

## Prerequisites

1. **coder4gov deployed** — Layers 0–4 must be applied first
2. **Bedrock models** — follow `docs/BEDROCK_SETUP.md` to enable Claude
3. **API keys** — OpenAI + Gemini keys stored in Secrets Manager

## Deploy

```bash
# 1. Additional data resources (OpenSearch, SES, S3)
cd infra/terraform/data
terraform init && terraform apply

# 2. GitLab EC2
cd ../gitlab
terraform init && terraform apply

# 3. Platform services (Istio, WAF, FluxCD)
cd ../platform
terraform init && terraform apply

# 4. FluxCD reconciles clusters/gov-demo/
```
