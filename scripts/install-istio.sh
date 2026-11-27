#!/bin/bash
set -e

ISTIO_VERSION="1.32.0"
ISTIO_DIR="$PWD/istio-$ISTIO_VERSION"

echo "Descargando Istio $ISTIO_VERSION..."

if [ ! -x "$ISTIO_DIR/bin/istioctl" ]; then
    curl -L https://istio.io/downloadIstio | \
      ISTIO_VERSION="$ISTIO_VERSION" sh -
fi

echo "Instalando istioctl..."

sudo install -m 0755 \
  "$ISTIO_DIR/bin/istioctl" \
  /usr/local/bin/istioctl

echo "Instalando Istio..."

istioctl install --set profile=demo -y

echo "Habilitando inyeccion de Envoy..."

kubectl label namespace default \
  istio-injection=enabled --overwrite

echo "Instalacion terminada."
