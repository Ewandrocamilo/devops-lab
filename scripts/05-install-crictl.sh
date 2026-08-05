#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common/functions.sh"
source "${SCRIPT_DIR}/common/config.sh"

require_root

log_info "======================================="
log_info "DevOps Lab - Instalando crictl"
log_info "======================================="

CRICTL_VERSION="v1.34.0"

log_info "Instalando crictl ${CRICTL_VERSION}..."

cd /tmp

curl -LO "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"

tar zxvf "crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" -C /usr/local/bin

rm -f "crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"

log_info "Configurando endpoint do containerd..."

cat <<EOF >/etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

log_info "Validando conexão com containerd..."

crictl info >/dev/null

log_success "Conexão com containerd validada."
log_success "crictl instalado com sucesso."
