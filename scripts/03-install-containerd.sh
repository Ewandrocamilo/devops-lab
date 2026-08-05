#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common/functions.sh"
source "${SCRIPT_DIR}/common/config.sh"

require_root

log_info "======================================="
log_info "DevOps Lab - Instalando Containerd"
log_info "======================================="

log_info "Instalando dependências..."

install_package ca-certificates
install_package curl
install_package gnupg

log_info "Criando diretório para chaves GPG..."

install -m 0755 -d /etc/apt/keyrings

if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    chmod a+r /etc/apt/keyrings/docker.gpg

fi

log_info "Adicionando repositório oficial do Docker..."

ARCH=$(dpkg --print-architecture)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
${CODENAME} stable
EOF

apt-get update

log_info "Instalando containerd.io..."

install_package containerd.io

mkdir -p /etc/containerd

log_info "Gerando configuração padrão..."

containerd config default >/etc/containerd/config.toml

log_info "Configurando SystemdCgroup..."

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' \
    /etc/containerd/config.toml

systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd

check_service containerd

log_info "Configurando parâmetros de rede Kubernetes..."

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

log_success "Parâmetros de rede Kubernetes configurados."

log_success "Containerd instalado e configurado com sucesso."
