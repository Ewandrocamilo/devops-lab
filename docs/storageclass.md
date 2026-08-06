# StorageClass

## Objetivo

Adicionar provisionamento dinâmico de armazenamento ao cluster Kubernetes.

## Problema encontrado

Durante a instalação do Grafana utilizando Helm, o PVC permaneceu em estado Pending.

## Diagnóstico

O cluster kubeadm não possuía uma StorageClass configurada.

Mensagem encontrada:

no persistent volumes available for this claim and no storage class is set

## Solução

- Instalação do local-path-provisioner
- Configuração da StorageClass local-path como padrão
- Provisionamento dinâmico habilitado

## Resultado

PVC → Bound

Pods → Running

Grafana utilizando armazenamento persistente.
