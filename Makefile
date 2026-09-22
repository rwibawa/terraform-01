TF_ENV ?= dev
TF_DIR := terraform/envs/$(TF_ENV)
CHART_DIR := fastapi-ws-chart
K8S_NAMESPACE := app
EKS_CLUSTER := $(EKS_CLUSTER)

.PHONY: tf-init tf-plan tf-apply tf-destroy helm-deploy helm-uninstall kubeconfig

tf-init:
    cd $(TF_DIR) && terraform init

tf-plan:
    cd $(TF_DIR) && terraform plan

tf-apply:
    cd $(TF_DIR) && terraform apply -auto-approve

tf-destroy:
    cd $(TF_DIR) && terraform destroy -auto-approve

kubeconfig:
    aws eks update-kubeconfig --name $(EKS_CLUSTER)

helm-deploy: kubeconfig
    helm upgrade --install fastapi-ws $(CHART_DIR) \
        -n $(K8S_NAMESPACE) --create-namespace

helm-uninstall: kubeconfig
    helm uninstall fastapi-ws -n $(K8S_NAMESPACE)
