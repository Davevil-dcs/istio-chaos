
#!/bin/bash
set -euo pipefail

CHAOS_VERSION="2.8.8"
NAMESPACE="chaos-mesh"
RUNTIME="containerd"
SOCKET="/run/containerd/containerd.sock"

echo "=========================================="
echo "       CHAOS MESH INSTALLATION"
echo "=========================================="

echo "[1/6] Checking requirements..."

for cmd in kubectl helm; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: $cmd is not installed."
        exit 1
    fi
done

echo "[2/6] Checking Kubernetes runtime..."

RUNTIMES=$(kubectl get nodes \
    -o jsonpath='{range .items[*]}{.status.nodeInfo.containerRuntimeVersion}{"\n"}{end}' \
    | sort -u)

if [[ "$RUNTIMES" != containerd* ]]; then
    echo "ERROR: Unsupported or mixed container runtime:"
    echo "$RUNTIMES"
    exit 1
fi

if [ ! -S "$SOCKET" ]; then
    echo "ERROR: containerd socket not found: $SOCKET"
    exit 1
fi

echo "[3/6] Adding Chaos Mesh Helm repository..."

helm repo add chaos-mesh https://charts.chaos-mesh.org \
    --force-update
helm repo update

echo "[4/6] Preparing namespace..."

kubectl create namespace "$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -

echo "[5/6] Installing Chaos Mesh $CHAOS_VERSION..."

helm upgrade --install chaos-mesh chaos-mesh/chaos-mesh \
    --namespace "$NAMESPACE" \
    --version "$CHAOS_VERSION" \
    --set chaosDaemon.runtime="$RUNTIME" \
    --set chaosDaemon.socketPath="$SOCKET"

echo "[6/6] Verifying Chaos Mesh..."

kubectl wait \
    --for=condition=Ready \
    pod \
    --all \
    -n "$NAMESPACE" \
    --timeout=300s

echo ""
echo "=========================================="
echo "   CHAOS MESH INSTALLED SUCCESSFULLY"
echo "=========================================="

kubectl get pods -n "$NAMESPACE"
