# Internal Developer Platform

A self-service internal developer platform (IDP) on AWS EKS. A developer pushes application code, runs one GitHub Actions workflow, and gets back a pull request with a platform-standard Dockerfile, Helm chart, and CI/CD pipeline — wired end to end to auto-provision infrastructure and auto-deploy to Kubernetes. No manual YAML, no ticket to a platform team.

## Architecture

**Flow:** a developer's app code lands in `services/<name>/`. The scaffold workflow generates the DevOps wrapper around it and opens a PR. Once merged, the reusable CI pipeline builds the image and pushes it to ECR while Terraform provisions the matching ECR repository. Helm charts (auto-discovered) get picked up by an Argo CD `ApplicationSet`, which deploys the service to the cluster with zero manual `kubectl apply` steps.

## Stack

| Layer | Tool |
|---|---|
| Infrastructure | Terraform (VPC, EKS, IAM/IRSA, ECR) |
| Container orchestration | Amazon EKS (`idp-dev`, `ap-south-1`, Kubernetes 1.30) |
| Packaging | Helm |
| GitOps / delivery | Argo CD (`ApplicationSet`, git-directory generator) |
| CI/CD | GitHub Actions (reusable workflow + self-service scaffolder) |
| Service catalog | Backstage (`catalog-info.yaml`) |

## Repository structure

```
services/          Application code per service (app/, Dockerfile, requirements.txt)
charts/             Helm chart per service, cloned from the reference-service golden path
gitops/argocd/      Argo CD bootstrap: the ApplicationSet that auto-discovers charts/*
terraform/
  modules/          Reusable modules: vpc, iam, eks, ecr
  environments/dev/ Dev environment composition and state
.github/workflows/
  scaffold-service.yml       Self-service workflow: generates Dockerfile, Helm chart, CI for a new service
  service-ci-reusable.yml    Shared build → push → deploy pipeline every service CI calls into
  terraform-dev.yml          Plans/applies terraform/environments/dev on change (behind an approval gate)
docs/               Build notes and platform documentation
```

## Services

- **reference-service** — the golden path. Every new service's Dockerfile and Helm chart are cloned from this one.
- **payment-service**, **user-service** — services scaffolded from the golden path via the self-service workflow.

## Adding a new service

1. Push your application code to `services/<name>/` following the `reference-service` layout (an `app/` package exposing `/healthz` and `/readyz`, plus `requirements.txt`).
2. Run the **Scaffold new service** workflow (`workflow_dispatch`) with your service name and resource inputs (port, replicas, CPU/memory).
3. Review the generated PR — it adds `services/<name>/Dockerfile`, `charts/<name>/`, and `.github/workflows/<name>-ci.yml`.
4. Merge. From there, everything is automatic:
   - `charts/<name>/Chart.yaml` landing triggers `terraform-dev`, which provisions the service's ECR repository (behind a manual approval gate).
   - The new `<name>-ci.yml` builds and pushes the image, then bumps the chart's `values.yaml` image tag.
   - Argo CD's `ApplicationSet` picks up `charts/<name>/` and deploys it to its own namespace — no manual step required.

## Local setup

```bash
cd terraform/environments/dev
terraform init
terraform apply -target=module.eks   # first run only — IRSA needs a real OIDC issuer URL
terraform apply

aws eks update-kubeconfig --region ap-south-1 --name idp-dev
```

## Notes

- Image tags are always the short git SHA — never `:latest` — so every deploy is traceable back to a commit.
- The Argo CD sync policy uses `Replace=true` to handle immutable field changes (e.g. `Deployment.spec.selector`) via delete-and-recreate instead of failing.
- The scaffold workflow's PR step requires a PAT with `workflow` scope (`SCAFFOLD_PAT`) — the default `GITHUB_TOKEN` is blocked from touching `.github/workflows/**`.
