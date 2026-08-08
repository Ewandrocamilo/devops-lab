# Troubleshooting - Recuperação do Grafana

## Contexto

O Grafana estava funcionando normalmente no namespace `monitoring`, utilizando armazenamento persistente através de um PVC de 10 GiB provisionado pela StorageClass `local-path`.

Após um reinício do `k8s-worker1`, o Grafana deixou de iniciar corretamente.

## Sintomas

O status do laboratório mostrou:

```text
monitoring   pod/grafana-...   0/1   Unknown
monitoring   deployment.apps/grafana   0/2
```

Os pods do Grafana estavam no `k8s-worker1`.

Durante a investigação, foram encontrados eventos relacionados ao Flannel:

```text
failed to setup network for sandbox
plugin type="flannel" failed (add):
failed to load flannel 'subnet.env' file
open /run/flannel/subnet.env: no such file or directory
```

## Diagnóstico do Flannel

O `k8s-worker1` havia sido reiniciado.

Após o reboot, o Flannel precisou recriar o arquivo:

```text
/run/flannel/subnet.env
```

O log posteriormente confirmou a recuperação:

```text
Wrote subnet file to /run/flannel/subnet.env
Running backend.
```

O nó voltou a apresentar:

```text
NetworkUnavailable: False
Ready: True
Reason: FlannelIsUp
```

Portanto, o problema inicial de rede foi temporário e o Flannel voltou a funcionar normalmente.

## Problema encontrado no Grafana

Após a recuperação da rede, o Grafana continuou sem iniciar.

O `init container` `init-chown-data` apresentava:

```text
chown: /var/lib/grafana/csv: Permission denied
chown: /var/lib/grafana/pdf: Permission denied
chown: /var/lib/grafana/png: Permission denied
```

O container executava:

```text
chown -R 472:472 /var/lib/grafana
```

com:

```text
runAsUser: 0
capabilities:
  add:
    - CHOWN
```

## Investigação do armazenamento

O PVC permaneceu íntegro:

```text
STATUS: Bound
CAPACITY: 10Gi
ACCESS MODES: RWO
STORAGECLASS: local-path
```

O PV utilizava:

```text
/opt/local-path-provisioner/pvc-21b0d3b1-070d-4193-b0b0-080a1e3eebbb_monitoring_grafana
```

no `k8s-worker1`.

Os arquivos do Grafana já pertenciam ao UID/GID `472:472`:

```text
csv        472:472
pdf        472:472
png        472:472
plugins    472:472
grafana.db 472:472
```

O filesystem era `ext4` e estava montado como `rw`.

Também foram verificados atributos especiais com `lsattr`, sem indicação de `immutable` ou `append-only`.

## Testes realizados

Foi testado `chown` diretamente no host:

```text
sudo chown 472:472 <diretório>
```

O comando funcionou.

Também foi criado um Pod temporário no `k8s-worker1` para testar `chown` dentro de um container utilizando `UID 0` e `CAP_CHOWN`.

O teste funcionou:

```text
0:0
↓
472:472
```

Isso descartou um problema geral de `chown`, containerd ou `CAP_CHOWN`.

Também foi verificado o AppArmor. Não foram encontrados eventos `DENIED` relacionados ao Grafana ou ao `chown`.

## Análise do Helm

O release utilizava:

```text
grafana-10.5.15
Grafana 12.3.1
```

O Helm Chart possuía a configuração:

```yaml
initChownData:
  enabled: true
```

O chart documentava que essa opção controla a execução do container responsável por ajustar o ownership dos dados.

Como o volume já possuía os arquivos pertencentes ao UID/GID `472:472`, o `init-chown-data` não era necessário para o nosso ambiente.

## Correção

O arquivo:

```text
helm/grafana/values.yaml
```

foi alterado para:

```yaml
replicas: 1

service:
  type: NodePort

persistence:
  enabled: true
  size: 10Gi

initChownData:
  enabled: false
```

Também foi reduzido o número de réplicas de 2 para 1.

Essa configuração é mais adequada para o laboratório porque o Grafana utiliza um PVC com acesso `RWO` e o armazenamento contém o banco `grafana.db`.

A alteração foi aplicada através do Helm:

```bash
helm upgrade grafana grafana/grafana \
  -n monitoring \
  -f ~/devops-lab/helm/grafana/values.yaml
```

## Resultado

Após o upgrade:

```text
grafana-c4b4d56d9-zxl4z   1/1   Running
```

Deployment:

```text
grafana   1/1   1   1
```

PVC:

```text
grafana   Bound   10Gi   RWO   local-path
```

O `init-chown-data` deixou de existir no Pod.

O Grafana voltou a responder normalmente através do NodePort:

```text
30683
```

O login foi validado com sucesso e a aplicação abriu normalmente.

## Conclusão

O reboot do `k8s-worker1` provocou uma interrupção temporária na inicialização do Flannel. O Flannel posteriormente se recuperou e recriou o `subnet.env`.

Durante a recuperação do Grafana, entretanto, o `init-chown-data` falhou ao executar o `chown` sobre alguns diretórios do PVC.

A investigação confirmou que:

* o PVC não estava corrompido;
* o filesystem estava saudável;
* os dados pertenciam ao UID/GID `472:472`;
* o `chown` funcionava no host;
* `CAP_CHOWN` funcionava em containers;
* não havia bloqueio do AppArmor relacionado ao Grafana.

A solução foi desabilitar o `initChownData` através do `values.yaml` e manter uma única réplica do Grafana.

O PVC e o banco `grafana.db` foram preservados.

## Aprendizado

O incidente demonstrou a relação entre diferentes componentes do ambiente Kubernetes:

```text
Worker
  ↓
Flannel / CNI
  ↓
Pod
  ↓
Init Container
  ↓
PVC / Storage
  ↓
Aplicação Grafana
```

Também reforçou a importância de diagnosticar o problema por camadas antes de realizar alterações destrutivas no armazenamento.
