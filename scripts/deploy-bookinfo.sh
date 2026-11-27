#!/bin/bash
set -e

ISTIO_VERSION="1.32.0"
ISTIO_DIR="$PWD/istio-$ISTIO_VERSION"
BOOKINFO_YAML="$ISTIO_DIR/samples/bookinfo/platform/kube/bookinfo.yaml"

if [ ! -f "$BOOKINFO_YAML" ]; then
    echo "No se encontro $BOOKINFO_YAML. Descargando Istio $ISTIO_VERSION..."
    curl -L https://istio.io/downloadIstio | \
      ISTIO_VERSION="$ISTIO_VERSION" sh -
fi

echo "Desplegando Bookinfo..."
kubectl apply -f "$BOOKINFO_YAML"

echo "Esperando a que los pods esten listos..."
kubectl wait --for=condition=Ready pods --all --timeout=180s

echo "Verificando servicios y pods..."
kubectl get services,pods
