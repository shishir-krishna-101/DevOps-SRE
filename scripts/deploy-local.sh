#!/usr/bin/env bash
set -euo pipefail
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f monitoring/prometheus-values.yaml
helm upgrade --install loki grafana/loki -n monitoring -f monitoring/loki-values.yaml
helm upgrade --install alloy grafana/alloy -n monitoring -f monitoring/alloy-values.yaml
kubectl apply -f monitoring/alerts.yaml
kubectl apply -f monitoring/dashboards/dashboard-configmap.yaml
kubectl apply -f argocd/application.yaml
echo "Resources submitted; verify Argo CD and monitoring pods."
