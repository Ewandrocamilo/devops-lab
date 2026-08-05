#!/usr/bin/env bash

# ==================================================
# DevOps Lab - Status
# Autor: Ewandro Camilo
#
# Objetivo:
# Exibir a saúde e o estado atual do laboratório
# Kubernetes.
# ==================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/common/functions.sh"
source "${SCRIPT_DIR}/common/config.sh"

show_banner() {

    echo "=========================================="
    echo "         DEVOPS LAB - STATUS"
    echo "=========================================="
    echo "Data      : $(date '+%d/%m/%Y %H:%M:%S')"
    echo "Host      : $(hostname)"
    echo "Usuário   : $(whoami)"
    echo "Diretório : ${PROJECT_DIR}"
    echo "=========================================="
    echo

}

show_versions() {

    print_section "VERSÕES"

    local kubectl_version
    local kubeadm_version
    local containerd_version
    local crictl_version

    kubectl_version=$(kubectl version --client 2>/dev/null | awk '/Client Version:/ {print $3}')
    kubeadm_version=$(kubeadm version -o short)
    containerd_version=$(containerd --version | awk '{print $3}')
    crictl_version=$(crictl --version | awk '{print $3}')

    printf "%-15s %s\n" "Kubernetes:" "${kubectl_version}"
    printf "%-15s %s\n" "kubeadm:" "${kubeadm_version}"
    printf "%-15s %s\n" "containerd:" "${containerd_version}"
    printf "%-15s %s\n" "crictl:" "${crictl_version}"

}

show_cluster() {

    print_section "CLUSTER"

    kubectl get nodes -o wide

}

show_namespaces() {

    print_section "NAMESPACES"

    kubectl get ns

}

show_storage() {

    print_section "STORAGECLASS"

    kubectl get storageclass

    echo

    print_section "PERSISTENT VOLUMES"

    kubectl get pv

    echo

    print_section "PERSISTENT VOLUME CLAIMS"

    kubectl get pvc -A

}

show_ingress() {

    print_section "INGRESS"

    kubectl get ingress -A

}

show_resources() {

    print_section "RECURSOS"

    kubectl get all -A

}

show_yaml_files() {

    print_section "ARQUIVOS YAML"

    find "${PROJECT_DIR}/kubernetes" \
        -type f \
        -name "*.yaml" \
        | sort

}

show_project_tree() {

    print_section "ESTRUTURA DO PROJETO"

    tree -L 3 "${PROJECT_DIR}"

}

show_summary() {

    print_section "RESUMO"

    local nodes
    local namespaces
    local pods
    local services
    local ingress
    local pv
    local pvc

    nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    namespaces=$(kubectl get ns --no-headers 2>/dev/null | wc -l)
    pods=$(kubectl get pods -A --no-headers 2>/dev/null | wc -l)
    services=$(kubectl get svc -A --no-headers 2>/dev/null | wc -l)
    ingress=$(kubectl get ingress -A --no-headers 2>/dev/null | wc -l)
    pv=$(kubectl get pv --no-headers 2>/dev/null | wc -l)
    pvc=$(kubectl get pvc -A --no-headers 2>/dev/null | wc -l)

    printf "%-22s %s\n" "Nodes:" "${nodes}"
    printf "%-22s %s\n" "Namespaces:" "${namespaces}"
    printf "%-22s %s\n" "Pods:" "${pods}"
    printf "%-22s %s\n" "Services:" "${services}"
    printf "%-22s %s\n" "Ingress:" "${ingress}"
    printf "%-22s %s\n" "Persistent Volumes:" "${pv}"
    printf "%-22s %s\n" "Persistent Claims:" "${pvc}"

    echo
    echo "=========================================="

    if kubectl get nodes --no-headers 2>/dev/null | awk '{print $2}' | grep -q "NotReady"; then
        log_warn "LABORATÓRIO COM ALERTAS"
    else
        log_success "LABORATÓRIO SAUDÁVEL"
    fi

}

main() {

    show_banner

    show_versions

    echo
    show_cluster

    echo
    show_namespaces

    echo
    show_storage

    echo
    show_ingress

    echo
    show_resources

    echo
    show_yaml_files

    echo
    show_project_tree

    echo
    show_summary

}

main "$@"
