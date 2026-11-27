#!/bin/bash

echo "===== NODOS ====="
kubectl get nodes

echo "===== PODS ====="
kubectl get pods -A

echo "===== SERVICIOS ====="
kubectl get services

echo "===== GATEWAY Y VIRTUALSERVICE ====="
kubectl get gateway,virtualservice

echo "===== ANALISIS ISTIO ====="
istioctl analyze

echo "===== ACCESO A BOOKINFO ====="
curl -I http://localhost:31169/productpage
