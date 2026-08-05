#!/usr/bin/env bash

set -euo pipefail

# ==================================================
# DevOps Lab - Common Functions
# Biblioteca compartilhada entre todos os scripts
# ==================================================

# ==========================================
# Colors
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==========================================
# Logging
# ==========================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[ OK ]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# ==========================================
# Output Helpers
# ==========================================

print_section() {
    echo
    echo "========== $1 =========="
}

# ==========================================
# System Validation
# ==========================================

require_root() {

    if [[ "$EUID" -ne 0 ]]; then
        log_error "Execute este script com sudo."
        exit 1
    fi

}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_service() {

    local service="$1"

    if systemctl is-active --quiet "$service"; then
        log_success "Serviço ${service} está ativo."
    else
        log_error "Serviço ${service} não está ativo."
        return 1
    fi

}

# ==========================================
# Validation Helpers
# ==========================================

check_command() {

    local command="$1"

    if command_exists "$command"; then
        log_success "Comando '${command}' encontrado."
        return 0
    else
        log_error "Comando '${command}' não encontrado."
        return 1
    fi

}

check_sysctl() {

    local key="$1"
    local expected="$2"

    local current
    current=$(sysctl -n "$key" 2>/dev/null || true)

    if [[ "$current" == "$expected" ]]; then
        log_success "${key} = ${expected}"
        return 0
    else
        log_error "${key} = ${current:-N/A} (esperado: ${expected})"
        return 1
    fi

}

print_step() {

    echo
    log_info "$1"

}


# ==========================================
# Package Management
# ==========================================

install_package() {

    local package="$1"

    if dpkg -s "$package" &>/dev/null; then
        log_info "${package} já está instalado."
    else
        log_info "Instalando ${package}..."
        apt-get install -y --no-install-recommends "$package"
    fi

}
