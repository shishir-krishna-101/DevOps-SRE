# Task 2 — Argo CD GitOps

Install Argo CD in a local Kind, Minikube or K3d cluster. Example with Kind:

```bash
kind create cluster --name devops-sre
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment --all -n argocd
```

Apply the Application:

```bash
kubectl apply -f argocd/application.yaml
kubectl get applications -n argocd
kubectl get all -n devops-sre
kubectl get endpoints -n devops-sre devops-sre
```

Argo CD tracks the `k8s/` directory on main, uses automated sync, self-heal and prune to reconcile the cluster to Git.

The three Deployment manifests each have one version slot and a shared application label. The Service selects that shared label and routes port 80 to application port 8080. All app containers request 128Mi and have a 400Mi memory limit. The app provides `/healthcheck` on port 8080. ConfigMap stores non-secret settings; since the app does not currently need credentials, the example Secret is a template only. The ServiceAccount token is not auto-mounted; the app Role grants no permissions. The initContainer performs a preflight check, NetworkPolicy requires a compatible CNI (such as Calico or Cilium), and ResourceQuota caps namespace resources.

The current release workflow builds one image per merged PR, not a three-image matrix. These manifests reference the current existing GHCR tag to avoid inventing tags. To run three distinct image versions, publish/verify three distinct tags and adjust each versioned manifest. The release workflow also needs updating to change all three manifests rather than the original single Deployment file.
