# Online Boutique – Cloud-Native Observability & Chaos Engineering

## 1. Overview

This project deploys Google's Online Boutique microservices application on Amazon EKS, with an end-to-end observability and chaos engineering platform.

The infrastructure is provisioned using Terraform. Application images are stored in Amazon ECR and deployed using GitHub Actions.

The monitoring platform provides metrics, logs, distributed traces, anomaly detection, alerting, and controlled fault injection.

## 2. Architecture

The system includes:

* **Infrastructure:** AWS VPC, EKS, ECR, EBS and IAM.
* **Application:** Online Boutique microservices.
* **CI/CD:** GitHub Actions with AWS OIDC.
* **Metrics:** Prometheus and Grafana.
* **Logs:** Loki and Promtail/Alloy.
* **Traces:** Tempo and OpenTelemetry Collector.
* **Alerting:** Prometheus Rules, Alertmanager and Telegram.
* **Chaos Engineering:** Chaos Mesh.

Add the architecture diagram in `docs/architecture.md`.

## 3. Prerequisites

Required tools:

* AWS CLI
* Terraform
* kubectl
* Helm
* Docker
* Git
* An AWS account with the required IAM permissions

## 4. Repository Structure

| Directory            | Purpose                                                |
| -------------------- | ------------------------------------------------------ |
| `terraform-aws/`     | AWS infrastructure provisioning                        |
| `src/`               | Online Boutique source code                            |
| `k8s/`               | Kubernetes application manifests and chaos experiments |
| `helm-values/`       | Monitoring and Chaos Mesh configuration                |
| `prometheus-rules/`  | Alert and anomaly detection rules                      |
| `dashboards/`        | Grafana dashboards as code                             |
| `scripts/`           | Deployment, validation and cleanup                     |
| `.github/workflows/` | CI/CD pipelines                                        |
| `docs/`              | Architecture, deployment and validation documentation  |

## 5. Deployment Guide

### Step 1 – Provision AWS infrastructure

```bash
cd terraform-aws
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 2 – Connect to EKS

```bash
aws eks update-kubeconfig \
  --region ap-southeast-1 \
  --name observability-demo-cluster

kubectl get nodes
```

### Step 3 – Deploy Online Boutique

Build and push application images to Amazon ECR.

Configure the EKS overlay with the correct ECR image names and commit SHA.

```bash
kubectl apply -k k8s/overlays/eks
kubectl get pods -n online-boutique
```

Alternatively, trigger the GitHub Actions deployment workflow.

### Step 4 – Deploy the monitoring stack

```bash
bash scripts/deploy-monitoring.sh
```

Verify:

```bash
kubectl get pods -n monitoring
```

### Step 5 – Deploy Chaos Mesh

Install Chaos Mesh using the pinned Helm chart and the values in `helm-values/chaos-mesh-values.yaml`.

Verify that its controller, daemon and CRDs are healthy.

### Step 6 – Access Grafana

```bash
kubectl port-forward \
  -n monitoring \
  svc/kube-prometheus-stack-grafana \
  3000:80
```

Open `http://localhost:3000`.

Use credentials provided through the configured secret-management mechanism.

## 6. Data Retention

| Data source        | Retention |
| ------------------ | --------- |
| Prometheus metrics | 7 days    |
| Loki logs          | 3 days    |
| Tempo traces       | 2 days    |

Retention is configured through the corresponding Helm values.

## 7. Observability Validation

Verify:

* Application metrics in Prometheus.
* Logs in Loki.
* Distributed traces in Tempo.
* Service graph metrics from the OpenTelemetry Collector.
* Grafana dashboard availability.
* Alertmanager notification delivery to Telegram.
* Log-to-trace correlation using Trace ID.

## 8. Chaos Engineering

The E2E workflow runs:

1. Pod Kill on cartservice.
2. Network Delay between frontend and checkoutservice.
3. CPU Stress on recommendationservice.

```bash
bash scripts/run-chaos-e2e.sh
```

Observe system behavior and recovery using Grafana, Tempo, Loki and Alertmanager.

## 9. E2E Validation

```bash
bash scripts/validate-e2e.sh
```

Detailed validation procedures and evidence are documented in `docs/e2e-validation.md`.

## 10. Cleanup

Stop active chaos experiments before removing the infrastructure.

```bash
cd terraform-aws
terraform plan -destroy
terraform destroy
```

Review AWS resources after cleanup, including any persistent storage, load balancers and manually created resources.

## 11. Troubleshooting

See `docs/troubleshooting.md` for known issues related to EKS connectivity, container runtime, telemetry ingestion, Grafana, and Chaos Mesh.

## 12. References

* Google Online Boutique
* AWS EKS documentation
* Terraform AWS EKS module
* Prometheus Operator
* Grafana Loki and Tempo
* OpenTelemetry
* Chaos Mesh
