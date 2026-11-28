
#!/bin/bash
set -euo pipefail

# ==========================================
# Bookinfo deployment
# ==========================================

ISTIO_VERSION="1.32.0"
NAMESPACE="bookinfo"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

ISTIO_DIR="$PROJECT_DIR/.tools/istio-$ISTIO_VERSION"
BOOKINFO_DIR="$PROJECT_DIR/bookinfo"

echo "=========================================="
echo "       BOOKINFO DEPLOYMENT"
echo "=========================================="

# 1. Check requirements
echo "[1/6] Checking requirements..."

for cmd in kubectl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: $cmd is not installed."
        exit 1
    fi
done

if [ ! -d "$ISTIO_DIR" ]; then
    echo "ERROR: Istio installation directory not found."
    echo "Run install-istio.sh first."
    exit 1
fi

# 2. Verify Istio
echo "[2/6] Checking Istio..."

kubectl rollout status deployment/istiod \
    -n istio-system --timeout=180s

# 3. Prepare Bookinfo manifests
echo "[3/6] Preparing Bookinfo manifests..."

mkdir -p "$BOOKINFO_DIR"

cp "$ISTIO_DIR/samples/bookinfo/platform/kube/bookinfo.yaml" \
    "$BOOKINFO_DIR/bookinfo.yaml"

cp "$ISTIO_DIR/samples/bookinfo/networking/bookinfo-gateway.yaml" \
    "$BOOKINFO_DIR/bookinfo-gateway.yaml"

# 4. Configure namespace
echo "[4/6] Configuring namespace..."

kubectl create namespace "$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -

kubectl label namespace "$NAMESPACE" \
    istio-injection=enabled --overwrite

# 5. Deploy Bookinfo
echo "[5/6] Deploying Bookinfo..."

kubectl apply -n "$NAMESPACE" \
    -f "$BOOKINFO_DIR/bookinfo.yaml"

kubectl apply -n "$NAMESPACE" \
    -f "$BOOKINFO_DIR/bookinfo-gateway.yaml"

# 6. Verify deployment
echo "[6/6] Verifying Bookinfo..."

for deployment in details-v1 productpage-v1 ratings-v1 reviews-v1; do
    kubectl rollout status deployment/"$deployment" \
        -n "$NAMESPACE" --timeout=180s
done

echo ""
echo "=========================================="
echo "      BOOKINFO DEPLOYED SUCCESSFULLY"
echo "=========================================="

echo ""
echo "Deployments:"
kubectl get deployments -n "$NAMESPACE"

echo ""
echo "Pods:"
kubectl get pods -n "$NAMESPACE"

echo ""
echo "Services:"
kubectl get services -n "$NAMESPACE"

echo ""
echo "Gateway:"
kubectl get gateway,virtualservice -n "$NAMESPACE"

