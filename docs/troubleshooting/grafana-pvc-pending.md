Problema

Durante a instalação do Grafana utilizando Helm, os Pods permaneceram em estado Pending.

Sintoma

kubectl get pvc

STATUS: Pending

Diagnóstico

kubectl describe pvc

no persistent volumes available for this claim
and no storage class is set

Causa

O cluster kubeadm não possuía StorageClass configurada para provisionamento dinâmico.

Próxima etapa

Implementar uma StorageClass utilizando local-path-provisioner.
