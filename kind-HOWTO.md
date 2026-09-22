If you want to spin up a **local Kubernetes cluster** for development, testing, or running your FastAPI + WebSocket Helm chart, **Kind (Kubernetes IN Docker)** is one of the fastest ways to do it.

Here’s the clean, senior‑level way to install and use Kind on macOS, Linux, or Windows.

---

# ⭐ Install Kind (Kubernetes IN Docker)

Kind requires **Docker**. Make sure Docker Desktop or Docker Engine is installed first.

---

## 🔥 macOS & Linux (recommended)

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

For macOS:

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-darwin-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

---

## 🔥 Windows (PowerShell)

```powershell
curl.exe -Lo kind.exe https://kind.sigs.k8s.io/dl/v0.23.0/kind-windows-amd64
Move-Item kind.exe C:\Windows\System32\
```

---

# ⭐ Verify installation

```bash
kind --version
```

You should see something like:

```
kind v0.23.0
```

---

# ⭐ Create a local Kubernetes cluster

Use a simple default cluster:

```bash
kind create cluster --name fastapi-dev
```

Or use a multi‑node config (better for testing autoscaling):

**kind-cluster.yaml**

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

Create:

```bash
kind create cluster --name fastapi-dev --config kind-cluster.yaml
```

---

# ⭐ Load your FastAPI Docker image into Kind

If you build your FastAPI + WebSocket image locally:

```bash
docker build -t fastapi-ws:dev .
kind load docker-image fastapi-ws:dev --name fastapi-dev
```

Now your Kind cluster can run your image without pushing to ECR.

---

# ⭐ Deploy your Helm chart to Kind

```bash
kubectl create namespace app
helm upgrade --install fastapi-ws ./fastapi-ws-chart -n app
```

---

# ⭐ Check pods

```bash
kubectl get pods -n app
```

---

# ⭐ Port-forward to test WebSockets locally

```bash
kubectl port-forward svc/fastapi-ws 8080:80 -n app
```

Now your FastAPI WebSocket endpoint is available at:

```
ws://localhost:8080/ws
```

---

# ⭐ Delete the cluster

```bash
kind delete cluster --name fastapi-dev
```

---

# If you want, I can also generate:

🔥 A **Kind + local Kafka + local Redis** full dev stack  
🔥 A **docker-compose.yml** for your FastAPI + Kafka + Redis simulation  
🔥 A **Kind ingress setup** for local domain routing  
🔥 A **Kind cluster with MetalLB** for LoadBalancer simulation  

Just tell me what direction you want next.


### 🔥 Kind + local Kafka + local Redis full dev stack

**Idea:**  
- Kind runs your FastAPI + WebSocket service (via Helm).  
- Docker Compose runs Kafka + Zookeeper + Redis locally.  
- FastAPI connects to `localhost` Kafka/Redis from inside the cluster via host networking (`host.docker.internal` on macOS/Windows, or node IP on Linux).

---

### 🔥 `docker-compose.yml` for FastAPI + Kafka + Redis simulation

```yaml
version: "3.8"

services:
  zookeeper:
    image: bitnami/zookeeper:3.8
    environment:
      - ZOO_ENABLE_AUTH=no
      - ZOO_CLIENT_PORT=2181
    ports:
      - "2181:2181"

  kafka:
    image: bitnami/kafka:3.6
    depends_on:
      - zookeeper
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_LISTENERS=PLAINTEXT://:9092
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092
      - KAFKA_ALLOW_PLAINTEXT_LISTENER=yes
    ports:
      - "9092:9092"

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  fastapi-local:
    image: fastapi-ws:dev
    build: .
    environment:
      - KAFKA_BOOTSTRAP=host.docker.internal:9092
      - REDIS_ENDPOINT=host.docker.internal:6379
    ports:
      - "8000:80"
```

Run:

```bash
docker-compose up -d
```

---

### 🔥 Kind ingress setup for local domain routing

1. **Create Kind cluster:**

```yaml
# kind-ingress-cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
```

```bash
kind create cluster --name fastapi-dev --config kind-ingress-cluster.yaml
```

2. **Install NGINX Ingress:**

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

3. **Ingress for FastAPI WebSockets:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fastapi-ws-ingress
  namespace: app
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
spec:
  rules:
    - host: fastapi.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: fastapi-ws
                port:
                  number: 80
```

Add to `/etc/hosts`:

```text
127.0.0.1 fastapi.local
```

Now:

- HTTP: `http://fastapi.local/`
- WebSocket: `ws://fastapi.local/ws`

---

### 🔥 Kind cluster with MetalLB for LoadBalancer simulation

1. **Kind config with extra ports:**

```yaml
# kind-metallb-cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 8080
        protocol: TCP
      - containerPort: 443
        hostPort: 8443
        protocol: TCP
  - role: worker
```

```bash
kind create cluster --name fastapi-lb --config kind-metallb-cluster.yaml
```

2. **Install MetalLB:**

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
```

3. **Configure IP address pool:**

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
    - 172.18.255.1-172.18.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: kind-l2
  namespace: metallb-system
spec:
  ipAddressPools:
    - kind-pool
```

4. **Expose FastAPI service as LoadBalancer:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: fastapi-ws
  namespace: app
spec:
  type: LoadBalancer
  selector:
    app: fastapi-ws
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
      name: http
```

Then:

```bash
kubectl get svc -n app
```

Use the assigned external IP (mapped via MetalLB) to hit your FastAPI service locally.