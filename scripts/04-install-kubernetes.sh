#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common/functions.sh"
source "${SCRIPT_DIR}/common/config.sh"

require_root

#############################################
# Kernel modules
#############################################

log_info "Configurando módulos do kernel..."

cat <<EOF | tee /etc/modules-load.d/kubernetes.conf >/dev/null
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

#############################################
# Sysctl
#############################################

log_info "Configurando parâmetros de rede..."

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf >/dev/null
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

log_info "======================================="
log_info "DevOps Lab - Instalando Kubernetes"
log_info "======================================="

log_info "Versão configurada: ${KUBERNETES_VERSION}"

install_package apt-transport-https
install_package ca-certificates
install_package curl
install_package gpg

log_info "Adicionando repositório oficial do Kubernetes..."

mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/Release.key" \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/ /" \
| tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

apt update

log_info "Instalando kubelet, kubeadm e kubectl..."

install_package kubelet
install_package kubeadm
install_package kubectl

apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet

log_success "Kubernetes instalado com sucesso."
