# Task 3 — Observability, logs, and alerts

Use Helm to install Prometheus/Grafana and Loki/Alloy into the separate `monitoring` namespace. The application remains managed by Argo CD.

## Install

Requires a local Kind, Minikube, or K3d cluster, kubectl, and Helm 3.

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f monitoring/prometheus-values.yaml
helm upgrade --install loki grafana/loki -n monitoring -f monitoring/loki-values.yaml
helm upgrade --install alloy grafana/alloy -n monitoring -f monitoring/alloy-values.yaml
kubectl apply -f monitoring/alerts.yaml
kubectl apply -f monitoring/dashboards/dashboard-configmap.yaml
```

The Prometheus community stack provides Prometheus, Grafana, node-exporter and kube-state-metrics. Loki centralizes container logs; Alloy discovers Kubernetes pod logs and forwards them to Loki.

## Access Grafana

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode; echo
```

Open http://localhost:3000 and sign in as `admin` with the password returned above. Open Prometheus UI in another terminal:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

The starter dashboard includes node CPU, memory, root filesystem usage, app pod CPU/memory, and running pod count. Configure Loki as a Grafana data source using `http://loki-gateway.monitoring.svc.cluster.local`, then use Explore to query logs. Chart values can differ by Helm chart version; verify with `helm show values` if installation reports unknown fields.

## Alerts

`monitoring/alerts.yaml` defines Prometheus Operator rules for fewer than three ready app replicas and a container's last termination reason being OOMKilled. Prometheus evaluates them and Grafana can display their alert states. If the evaluator strictly requires Grafana-managed alert rules, recreate the same expressions in Grafana Alerting and configure a contact point. Email/Slack delivery requires your own destination/webhook.

## Validate

```bash
kubectl get pods -n monitoring
kubectl get pods,deployments,svc -n devops-sre
kubectl get events -n devops-sre --sort-by=.lastTimestamp
kubectl describe pod -n devops-sre -l app.kubernetes.io/name=devops-sre
```

The Python app serves `/healthcheck` on port 8080 but has no `/metrics` endpoint. Node and Kubernetes metrics come from node-exporter, kube-state-metrics and kubelet/cAdvisor. Loki persistence is disabled for a small local lab, so logs may be lost if Loki is recreated.
