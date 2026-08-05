#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common/functions.sh"
source "${SCRIPT_DIR}/common/config.sh"

require_root

log_info "======================================="
log_info "DevOps Lab - Atualização do Sistema"
log_info "======================================="

log_info "Atualizando lista de pacotes..."
apt-get update

log_info "Atualizando sistema..."
apt-get full-upgrade -y

log_info "Instalando ferramentas básicas..."

PACKAGES=(
    curl
    wget
    vim
    git
    unzip
    jq
    net-tools
    apt-transport-https
    ca-certificates
    gnupg
    lsb-release
)

for package in "${PACKAGES[@]}"; do
    install_package "$package"
done

log_success "Sistema atualizado com sucesso!"
