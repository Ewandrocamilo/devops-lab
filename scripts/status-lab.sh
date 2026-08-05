#!/bin/bash

echo "=================================================="
echo " DEVOPS LAB - STATUS"
echo "=================================================="
echo "Data: $(date)"
echo "Hostname: $(hostname)"
echo

echo "========== VERSÕES =========="
kubectl version --client
echo
kubeadm version
echo
containerd --version
echo
crictl --version

echo
echo "========== CLUSTER =========="
kubectl get nodes -o wide

echo
echo "========== NAMESPACES =========="
kubectl get ns

echo
echo "========== STORAGECLASS =========="
kubectl get storageclass

echo
echo "========== PERSISTENT VOLUMES =========="
kubectl get pv

echo
echo "========== PERSISTENT VOLUME CLAIMS =========="
kubectl get pvc -A

echo
echo "========== INGRESS =========="
kubectl get ingress -A

echo
echo "========== TODOS OS RECURSOS =========="
kubectl get all -A

echo
echo "========== ARQUIVOS YAML =========="
find ~/devops-lab/kubernetes -maxdepth 1 -type f -name "*.yaml" | sort

echo
echo "========== ESTRUTURA DO PROJETO =========="
tree ~/devops-lab

echo
echo "=================================================="
echo " FIM DO RELATÓRIO"
echo "=================================================="
