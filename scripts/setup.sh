#!/bin/bash
set -e

echo "===== INSTALANDO ISTIO ====="
bash scripts/install-istio.sh

echo "===== DESPLEGANDO BOOKINFO ====="
bash scripts/deploy-bookinfo.sh

echo "===== VERIFICANDO ENTORNO ====="
bash scripts/verify.sh

echo "===== LABORATORIO LISTO ====="
