#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common/functions.sh"
source "${SCRIPT_DIR}/common/config.sh"

require_root

log_info "======================================="
log_info "DevOps Lab - Inicializando Cluster Kubernetes"
log_info "======================================="

CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')

log_info "IP do Control Plane: ${CONTROL_PLANE_IP}"
log_info "Pod Network CIDR: ${POD_NETWORK_CIDR}"

if [[ -f /etc/kubernetes/admin.conf ]]; then

    log_warn "Cluster Kubernetes já inicializado."
    exit 0

fi

log_info "Executando kubeadm init..."

kubeadm init \
    --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
    --pod-network-cidr="${POD_NETWORK_CIDR}" \
    --kubernetes-version="${KUBERNETES_FULL_VERSION}"

log_success "Cluster inicializado."

log_info "Configurando kubectl para usuário ubuntu..."

mkdir -p /home/ubuntu/.kube

cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config

chown ubuntu:ubuntu /home/ubuntu/.kube/config

log_success "kubectl configurado."

log_info "Instalando Flannel CNI..."

su - ubuntu -c "kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"

log_success "Flannel instalado."

log_info "Gerando comando para adicionar workers..."

mkdir -p /home/ubuntu/devops-lab/backups

kubeadm token create --print-join-command \
    > /home/ubuntu/devops-lab/backups/worker-join-command.sh

chmod +x /home/ubuntu/devops-lab/backups/worker-join-command.sh

log_success "Comando de join salvo."

log_success "Cluster Kubernetes pronto."
