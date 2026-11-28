#!/bin/bash
set -euo pipefail

# ==========================================
# Istio installation
# ==========================================

ISTIO_VERSION="1.32.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

TOOLS_DIR="$PROJECT_DIR/.tools"
ISTIO_DIR="$TOOLS_DIR/istio-$ISTIO_VERSION"
ISTIOCTL="$ISTIO_DIR/bin/istioctl"

echo "=========================================="
echo "       ISTIO INSTALLATION"
echo "=========================================="

# 1. Check required commands
echo "[1/5] Checking requirements..."

for cmd in kubectl curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: $cmd is not installed."
        exit 1
    fi
done

# 2. Check Kubernetes connection
echo "[2/5] Checking Kubernetes cluster..."

if ! kubectl get nodes; then
    echo "ERROR: Cannot communicate with Kubernetes."
    exit 1
fi

# 3. Download Istio if necessary
echo "[3/5] Preparing Istio $ISTIO_VERSION..."

if [ ! -x "$ISTIOCTL" ]; then
    mkdir -p "$TOOLS_DIR"

    if [ -d "$ISTIO_DIR" ]; then
        echo "ERROR: Istio directory exists but istioctl is missing."
        exit 1
    fi

    (
        cd "$TOOLS_DIR"
        curl -sSL https://istio.io/downloadIstio |
            ISTIO_VERSION="$ISTIO_VERSION" sh -
    )
fi

# 4. Install Istio
echo "[4/5] Installing Istio..."

"$ISTIOCTL" install --set profile=demo -y

# 5. Verify installation
echo "[5/5] Verifying Istio..."

kubectl rollout status deployment/istiod \
    -n istio-system --timeout=180s

kubectl rollout status deployment/istio-ingressgateway \
    -n istio-system --timeout=180s

echo ""
echo "=========================================="
echo "       ISTIO INSTALLED SUCCESSFULLY"
echo "=========================================="

kubectl get pods -n istio-system
