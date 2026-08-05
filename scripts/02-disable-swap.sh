#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common/functions.sh"
source "${SCRIPT_DIR}/common/config.sh"

require_root

log_info "======================================="
log_info "DevOps Lab - Desabilitando Swap"
log_info "======================================="

if swapon --show | grep -q .; then

    log_info "Desabilitando swap..."

    swapoff -a

else

    log_info "Swap já está desabilitada."

fi

log_info "Removendo entrada da swap do /etc/fstab..."

cp /etc/fstab /etc/fstab.bkp

sed -i '/ swap / s/^/#/' /etc/fstab

log_success "Swap desabilitada com sucesso."
