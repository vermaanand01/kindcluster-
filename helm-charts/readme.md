# 📌 Helm Parent-Child Chart Deployment Guide

## 📖 Overview
This guide provides step-by-step instructions for deploying multiple microservices using Helm with a **parent-child chart structure**. Each microservice has its own **separate Helm chart**, and the **parent chart** manages all child charts as dependencies.

---

## 🏗 Folder Structure
Below is the recommended folder structure for organizing the Helm charts:

```
helm-charts/                # ✅ Main project folder
  ├── charts/               # ✅ Contains all child charts
  │   ├── db-chart/         # ✅ Database Helm chart
  │   ├── redis-chart/      # ✅ Redis Helm chart
  │   ├── vote-chart/       # ✅ Voting App Helm chart
  │   ├── result-chart/     # ✅ Result Service Helm chart
  │   ├── worker-chart/     # ✅ Worker Service Helm chart
  ├── parent-chart/         # ✅ Parent Helm Chart
  │   ├── charts/           # (Populated after `helm dependency update`)
  │   ├── templates/        # (Optional, for global resources)
  │   ├── values.yaml       # (Overrides child chart values)
  │   ├── Chart.yaml        # (Manages child dependencies)
```

---

## 📌 Step-by-Step Deployment Process

### **1️⃣ Create Project Structure**
Run the following commands to create the required Helm charts:

```sh
mkdir helm-charts && cd helm-charts
mkdir charts  # Create charts directory
helm create charts/db-chart
helm create charts/redis-chart
helm create charts/vote-chart
helm create charts/result-chart
helm create charts/worker-chart
helm create parent-chart
```

---

### **2️⃣ Define Parent Chart and Dependencies**

📌 **File:** `parent-chart/Chart.yaml`

```yaml
apiVersion: v2
name: parent-chart
description: A parent chart to deploy all microservices
version: 1.0.0
dependencies:
  - name: db-chart
    version: 1.0.0
    repository: "file://../charts/db-chart"
  - name: redis-chart
    version: 1.0.0
    repository: "file://../charts/redis-chart"
  - name: vote-chart
    version: 1.0.0
    repository: "file://../charts/vote-chart"
  - name: result-chart
    version: 1.0.0
    repository: "file://../charts/result-chart"
  - name: worker-chart
    version: 1.0.0
    repository: "file://../charts/worker-chart"
```

---

### **3️⃣ Configure Child Charts**
Each child chart should have its own **values.yaml** and **Kubernetes manifests**.

📌 **Example: `charts/db-chart/values.yaml`**
```yaml
replicaCount: 1
image:
  repository: mysql
  tag: "8.0"
service:
  type: ClusterIP
  port: 3306
```

📌 **Example: `charts/db-chart/templates/deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-db
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - name: db
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 3306
```

Repeat this for other child charts (**redis-chart, vote-chart, result-chart, worker-chart**).

---

### **4️⃣ Update Dependencies**
Run the following command inside the `parent-chart/` directory:

```sh
helm dependency update parent-chart
```

This will fetch and place the child charts inside the `parent-chart/charts/` folder.

---

### **5️⃣ Deploy the Parent Chart**

Run the following command to deploy all microservices:

```sh
helm install myapp parent-chart
```

Check the status of deployments:
```sh
kubectl get pods
kubectl get services
```

---

### **6️⃣ Deploy Using ArgoCD**

#### **6.1 Install ArgoCD (If Not Installed)**

```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

#### **6.2 Expose ArgoCD Server**

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Now, access ArgoCD UI at: **https://localhost:8080**

#### **6.3 Login to ArgoCD CLI**

```sh
argocd login localhost:8080
argocd account update-password
```

#### **6.4 Create an Application in ArgoCD**
Create an ArgoCD Application to manage the Helm chart deployment:

```sh
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-helm
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/your-repo/helm-charts.git'  # Change this
    path: parent-chart
    targetRevision: HEAD
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

#### **6.5 Sync and Monitor the Deployment**

```sh
argocd app sync myapp-helm
argocd app get myapp-helm
```

This will deploy the **parent Helm chart**, which in turn deploys all child charts.

---

### **7️⃣ Upgrade or Uninstall the Deployment**

📌 **To upgrade the deployment:**
```sh
helm upgrade myapp parent-chart
```

📌 **To uninstall the deployment:**
```sh
helm uninstall myapp
```

📌 **To delete from ArgoCD:**
```sh
argocd app delete myapp-helm
```

---

## ✅ **Conclusion**
🎯 **You have successfully deployed a Helm-based microservices architecture using a Parent-Child chart structure and ArgoCD!** 🚀

This approach provides **better organization, modularity, scalability, and GitOps-based deployment automation.** 

If you have any issues, check logs using:
```sh
kubectl logs -f <pod-name>
```

Happy Helm & ArgoCD Deployments! 🎩 😊

