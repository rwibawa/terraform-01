# terraform-01
a modular Terraform project layout that can be uses to provision the core platform for that Python/FastAPI + Kafka/Kinesis + ECS/EKS + WebSockets, sub‑100ms telemetry system.

## 1. Repository Structure
```
terraform-01/
  envs/
    dev/
      main.tf
      backend.tf
      providers.tf
      variables.tf
    prod/
      main.tf
      backend.tf
      providers.tf
      variables.tf

  modules/
    network/
      main.tf
      variables.tf
      outputs.tf
    eks/
      main.tf
      variables.tf
      outputs.tf
    ecs/
      main.tf
      variables.tf
      outputs.tf
    kinesis_kafka/
      main.tf
      variables.tf
      outputs.tf
    rds/
      main.tf
      variables.tf
      outputs.tf
    redis_cache/
      main.tf
      variables.tf
      outputs.tf
    observability/
      main.tf
      variables.tf
      outputs.tf
    iam/
      main.tf
      variables.tf
      outputs.tf

  fastapi-ws-chart/
    Chart.yaml
    values.yaml
    templates/
      deployment.yaml
      service.yaml
      ingress.yaml
      configmap.yaml

```

## 2. 🔥 GitOps version using ArgoCD
ArgoCD Application manifest:
```yml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: fastapi-ws
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/fastapi-ws-gitops.git
    targetRevision: main
    path: fastapi-ws-chart
    helm:
      valueFiles:
        - values-prod.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

```

Keep the Helm chart + values-*.yaml in a GitOps repo, and ArgoCD continuously syncs EKS to that desired state.

## 3. 🔥 Local dev environment using Kind + Helm
kind-cluster.yaml
```yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
```

Create cluster:
```bash
kind create cluster --name fastapi-dev --config kind-cluster.yaml
kubectl create namespace app
helm upgrade --install fastapi-ws ./fastapi-ws-chart -n app
```