#!/usr/bin/env bash
set -e

AWS_REGION=${AWS_REGION:-us-west-2}
CLUSTER_NAME=${CLUSTER_NAME:-zainar-eks}
PROJECT_NAME=${PROJECT_NAME:-zainar-platform}

echo "[+] Installing AWS CLI, kubectl, Terraform, and Helm (if needed)..."

# AWS CLI (assumes Linux)
if ! command -v aws >/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

# kubectl
if ! command -v kubectl >/dev/null 2>&1; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
fi

# Terraform
if ! command -v terraform >/dev/null 2>&1; then
  TF_VERSION=1.6.0
  curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
  unzip terraform_${TF_VERSION}_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
fi

# Helm
if ! command -v helm >/dev/null 2>&1; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "[+] Configure AWS credentials (aws configure or SSO)..."
echo "    Run: aws configure   or   aws sso login --profile myprofile"

echo "[+] Provision infrastructure with Terraform..."
(
  cd terraform-01/envs/dev
  terraform init
  terraform apply -auto-approve \
    -var="project_name=${PROJECT_NAME}" \
    -var="aws_region=${AWS_REGION}"
)

echo "[+] Update kubeconfig for EKS..."
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"

echo "[+] Deploy FastAPI + WebSocket Helm chart..."
helm upgrade --install fastapi-ws ./fastapi-ws-chart -n app --create-namespace

echo "[+] Bootstrap complete."
