#!/usr/bin/env bash

# ==================================================
# DevOps Lab - Host Validation
# Autor: Ewandro Camilo
# Objetivo:
# Validar se o host está preparado para executar
# o laboratório Kubernetes.
# ==================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common/functions.sh"
source "${SCRIPT_DIR}/common/config.sh"

# ==========================================
# Validation Counters
# ==========================================

PASS=0
WARN=0
FAIL=0


show_banner() {

    echo "=========================================="
    echo "      DEVOPS LAB - HOST VALIDATION"
    echo "=========================================="
    echo "Data      : $(date '+%d/%m/%Y %H:%M:%S')"
    echo "Host      : $(hostname)"
    echo "Usuário   : $(whoami)"
    echo "Diretório : $(pwd)"
    echo "=========================================="
    echo

}

validate_os() {

    print_step "Validando Sistema Operacional"

    if grep -qi "ubuntu" /etc/os-release; then
        log_success "Ubuntu detectado."
        ((++PASS))
    else
        log_error "Sistema operacional não suportado."
        ((++FAIL))
    fi

}



validate_kernel() {

    print_step "Validando Kernel"

    local kernel_version

    kernel_version=$(uname -r)

    if [[ -n "$kernel_version" ]]; then
        log_success "Kernel Linux: ${kernel_version}"
        ((++PASS))
    else
        log_error "Não foi possível identificar a versão do Kernel."
        ((++FAIL))
    fi

}

validate_swap() {

    print_step "Validando Swap"

    if [[ -z "$(swapon --show)" ]]; then
        log_success "Swap desabilitado."
        ((++PASS))
    else
        log_error "Swap habilitado."
        ((++FAIL))
    fi

}

validate_cpu() {

    print_step "Validando CPU"

    local cpu_count

    cpu_count=$(nproc)

    if [[ -n "$cpu_count" ]]; then
        log_success "CPU(s) disponíveis: ${cpu_count}"
        ((++PASS))
    else
        log_error "Não foi possível identificar a CPU."
        ((++FAIL))
    fi

}

validate_memory() {

    print_step "Validando Memória"

    local memory

    memory=$(free -h | awk '/^Mem:/ {print $2}')

    if [[ -n "$memory" ]]; then
        log_success "Memória RAM: ${memory}"
        ((++PASS))
    else
        log_error "Não foi possível identificar a memória RAM."
        ((++FAIL))
    fi

}

validate_disk() {

    print_step "Validando Disco"

    local disk_usage

    disk_usage=$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')

    if [[ -z "$disk_usage" ]]; then
        log_error "Não foi possível identificar o uso do disco."
        ((++FAIL))
        return
    fi

    if (( disk_usage < 80 )); then
        log_success "Uso do disco: ${disk_usage}%"
        ((++PASS))
    elif (( disk_usage < 90 )); then
        log_warn "Uso do disco: ${disk_usage}% (atenção)"
        ((++WARN))
    else
        log_error "Uso do disco: ${disk_usage}% (crítico)"
        ((++FAIL))
    fi

}

validate_network() {

    print_step "Validando Rede"

    local interface
    local ipv4
    local gateway

    interface=$(ip route | awk '/default/ {print $5}')
    ipv4=$(ip -4 -o addr show "${interface}" | awk '{print $4}' | cut -d/ -f1)
    gateway=$(ip route | awk '/default/ {print $3}')

    # Interface
    if [[ -n "$interface" ]]; then
        log_success "Interface: ${interface}"
        ((++PASS))
    else
        log_error "Nenhuma interface de rede encontrada."
        ((++FAIL))
    fi

    # Endereço IP
    if [[ -n "$ipv4" ]]; then
        log_success "IPv4: ${ipv4}"
        ((++PASS))
    else
        log_error "Nenhum endereço IPv4 encontrado."
        ((++FAIL))
    fi

    # Gateway
    if [[ -n "$gateway" ]]; then
        log_success "Gateway: ${gateway}"
        ((++PASS))
    else
        log_error "Gateway padrão não encontrado."
        ((++FAIL))
    fi
    
    # DNS
    if getent hosts google.com >/dev/null 2>&1; then
    	log_success "DNS funcionando."
    	((++PASS))
    else
    	log_error "Falha na resolução DNS."
    	((++FAIL))
    fi


    # Conectividade
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        log_success "Conectividade com a Internet OK."
        ((++PASS))
    else
        log_error "Sem conectividade com a Internet."
        ((++FAIL))
    fi

}

validate_containerd() {

    print_step "Validando Containerd"

    local version

    # Binário
    if command -v containerd >/dev/null 2>&1; then
        log_success "Containerd instalado."
        ((++PASS))
    else
        log_error "Containerd não encontrado."
        ((++FAIL))
    fi

    # Serviço habilitado
    if systemctl is-enabled containerd >/dev/null 2>&1; then
        log_success "Serviço habilitado."
        ((++PASS))
    else
        log_error "Serviço não habilitado."
        ((++FAIL))
    fi

    # Serviço ativo
    if systemctl is-active containerd >/dev/null 2>&1; then
        log_success "Serviço em execução."
        ((++PASS))
    else
        log_error "Serviço parado."
        ((++FAIL))
    fi

    # Versão
    version=$(containerd --version | awk '{print $3}')

    if [[ -n "$version" ]]; then
        log_success "Versão: ${version}"
        ((++PASS))
    else
        log_warn "Não foi possível identificar a versão."
        ((++WARN))
    fi

    # Configuração
    if [[ -f /etc/containerd/config.toml ]]; then
        log_success "Configuração encontrada."
        ((++PASS))
    else
        log_error "Arquivo config.toml não encontrado."
        ((++FAIL))
    fi

}

validate_kubernetes() {

    print_step "Validando Kubernetes"

    # kubeadm
    if command -v kubeadm >/dev/null 2>&1; then
        log_success "kubeadm instalado."
        ((++PASS))
    else
        log_error "kubeadm não encontrado."
        ((++FAIL))
    fi

    # kubectl
    if command -v kubectl >/dev/null 2>&1; then
        log_success "kubectl instalado."
        ((++PASS))
    else
        log_error "kubectl não encontrado."
        ((++FAIL))
    fi

    # kubelet
    if command -v kubelet >/dev/null 2>&1; then
        log_success "kubelet instalado."
        ((++PASS))
    else
        log_error "kubelet não encontrado."
        ((++FAIL))
    fi

    # Serviço habilitado
    if systemctl is-enabled kubelet >/dev/null 2>&1; then
        log_success "Serviço kubelet habilitado."
        ((++PASS))
    else
        log_error "Serviço kubelet não habilitado."
        ((++FAIL))
    fi

    # Serviço em execução
    if systemctl is-active kubelet >/dev/null 2>&1; then
        log_success "Serviço kubelet em execução."
        ((++PASS))
    else
        log_error "Serviço kubelet parado."
        ((++FAIL))
    fi

}

validate_cluster() {

    print_step "Validando Cluster"

    local node
    local status

    node=$(hostname)

    # API Server
    if kubectl cluster-info >/dev/null 2>&1; then
        log_success "API Server acessível."
        ((++PASS))
    else
        log_error "Não foi possível acessar o cluster."
        ((++FAIL))
        return
    fi

    # Nó registrado
    if kubectl get nodes --no-headers | awk '{print $1}' | grep -qx "$node"; then
        log_success "Nó registrado no cluster."
        ((++PASS))
    else
        log_error "Nó não encontrado no cluster."
        ((++FAIL))
        return
    fi

    # Status
    status=$(kubectl get node "$node" --no-headers | awk '{print $2}')

    if [[ "$status" == "Ready" ]]; then
        log_success "Nó em estado Ready."
        ((++PASS))
    else
        log_error "Nó não está Ready (${status})."
        ((++FAIL))
    fi

}

show_summary() {

    echo
    echo "=========================================="
    echo "               RESUMO"
    echo "=========================================="

    printf "%-10s %d\n" "PASS:" "${PASS}"
    printf "%-10s %d\n" "WARN:" "${WARN}"
    printf "%-10s %d\n" "FAIL:" "${FAIL}"

    echo "=========================================="

    if (( FAIL == 0 )); then
        log_success "HOST APROVADO"
    else
        log_error "HOST REPROVADO"
    fi

}


main() {

    show_banner

    validate_os
    validate_kernel
    validate_swap
    validate_cpu
    validate_memory
    validate_disk
    validate_network
    validate_containerd
    validate_kubernetes
    validate_cluster

    show_summary

}

main "$@"
