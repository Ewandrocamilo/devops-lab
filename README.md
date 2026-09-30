# DevOps Lab

Laboratório pessoal desenvolvido para aplicar, de forma prática, conhecimentos de **DevOps, Linux, Containers, Kubernetes, Cloud, Git e automação**.

O projeto acompanha minha transição de carreira para a área de DevOps, utilizando um ambiente local baseado em máquinas virtuais Ubuntu executadas com Multipass.

O objetivo é construir, administrar, automatizar e documentar uma infraestrutura próxima de cenários encontrados em ambientes reais, incluindo implantação de aplicações, armazenamento, monitoramento e troubleshooting.

## Dashboard do projeto

O dashboard é um site estático em `site/index.html`, hospedado em um bucket S3 privado e distribuído pelo CloudFront. Ele não consulta API, banco de dados ou cluster ao vivo. O deploy é automatizado pelo GitHub Actions com OIDC.

### Prévia local

```bash
docker compose up --build -d dashboard
```

Abra [http://localhost:8081](http://localhost:8081). Esse serviço serve apenas os arquivos estáticos; API e PostgreSQL não são iniciados para a prévia.

### Provisionar a hospedagem AWS

O stack isolado está em `terraform/aws/static-site`. Informe um nome de bucket S3 globalmente único e rode:

```bash
cd terraform/aws/static-site
terraform init
terraform plan -var="site_bucket_name=SEU-NOME-UNICO"
terraform apply -var="site_bucket_name=SEU-NOME-UNICO"
```

O Terraform cria o bucket privado, CloudFront com Origin Access Control e uma política IAM de deploy anexada ao role GitHub Actions já usado pelo projeto. Depois, cadastre nas variáveis do repositório GitHub os outputs `site_bucket_name` e `distribution_id` como `DASHBOARD_S3_BUCKET` e `DASHBOARD_CLOUDFRONT_DISTRIBUTION_ID`. Um push em `main` publica o site. O endereço público é o output `distribution_domain_name`.

O stack EC2 existente em `terraform/aws` permanece separado e não é removido por esta migração. Depois de validar o site no CloudFront, revise o plano desse stack antes de decidir parar ou destruir recursos EC2; eles podem continuar gerando cobrança enquanto estiverem ativos.

### Seções

- **Overview** — resumo do projeto e do destino de hospedagem estática;
- **Architecture** — navegador, CloudFront, bucket privado e fluxo de deploy;
- **Infrastructure** — S3, CloudFront, Terraform e tecnologias do laboratório;
- **CI / CD** — GitHub Actions, OIDC, publicação no S3 e invalidação de cache;
- **Technical decisions** — escolhas atuais e trade-offs;
- **Lessons learned** — troubleshooting de hospedagem e do laboratório.

O Compose com API e PostgreSQL permanece para exercícios locais separados; esses serviços não são necessários para servir o site.

---

## 🎯 Objetivos

* Consolidar conhecimentos de Linux e infraestrutura;
* Praticar administração de clusters Kubernetes;
* Trabalhar com containers e orquestração;
* Automatizar tarefas utilizando Shell Script;
* Utilizar Git para versionamento e documentação;
* Praticar Helm para gerenciamento de aplicações Kubernetes;
* Implementar armazenamento persistente;
* Implementar monitoramento e observabilidade;
* Documentar problemas encontrados e suas soluções;
* Evoluir gradualmente o laboratório conforme novos conhecimentos são adquiridos.

---

## 🏗️ Ambiente

O laboratório utiliza máquinas virtuais Ubuntu executadas através do **Multipass**, formando um ambiente Kubernetes com:

* 1 Control Plane
* 2 Workers
* containerd como container runtime
* kubeadm para criação e administração do cluster
* Flannel como CNI

O ambiente é utilizado exclusivamente para estudo, testes e desenvolvimento do projeto.

---

## 🛠️ Tecnologias

### Implementadas

* Linux / Ubuntu
* Multipass
* Shell Script
* Git
* Kubernetes
* kubeadm
* kubectl
* containerd
* Flannel
* Docker (utilizado nos estudos e etapas anteriores do laboratório)
* Helm
* Kustomize
* Persistent Volumes
* PersistentVolumeClaims
* Local Path Provisioner
* Prometheus
* Grafana

### Kubernetes

O laboratório já utiliza recursos como:

* Namespaces
* Deployments
* Services
* ConfigMaps
* Secrets
* PersistentVolumes
* PersistentVolumeClaims
* Kustomization
* Ingress
* StorageClass
* Helm

---

## 📊 Monitoramento

Foi implementada uma stack de monitoramento baseada em kube-prometheus-stack, utilizando:

* Prometheus
* Grafana
* Alertmanager
* kube-state-metrics
* Node Exporter

A stack está integrada ao cluster Kubernetes e realizando a coleta de métricas do ambiente.

O Grafana está configurado para visualização das métricas e possui armazenamento persistente.

A observabilidade do laboratório ainda está em evolução, com próximos trabalhos voltados para:

* melhoria e organização dos dashboards;
* criação de visualizações específicas para o cluster;
* investigação de métricas e alertas;
* aprimoramento da observabilidade dos workloads;
* evolução das práticas de monitoramento.


## 🔧 Automação

O projeto possui scripts em Shell para automatizar tarefas relacionadas à preparação e administração do ambiente.

Entre eles:

* atualização do sistema;
* configuração de swap;
* instalação do containerd;
* instalação do Kubernetes;
* instalação do crictl;
* inicialização do cluster;
* configuração dos workers;
* validação do host;
* verificação do status do laboratório.

Os scripts possuem uma estrutura modular com funções compartilhadas e arquivos de configuração.

---

## 🧪 Troubleshooting

Um dos objetivos do projeto é documentar não apenas as implementações, mas também os problemas encontrados durante a construção do ambiente.

Alguns dos cenários já investigados incluem:

* recuperação de componentes do Kubernetes;
* problemas com Flannel;
* investigação de Pods em `CrashLoopBackOff`;
* problemas de PersistentVolumeClaim;
* configuração de armazenamento dinâmico;
* recuperação e validação do Grafana após reinicialização de workers;
* validação da comunicação entre componentes do cluster.

A documentação desses problemas faz parte do processo de aprendizado e busca reproduzir uma prática comum em ambientes DevOps: **identificar, investigar, corrigir e documentar incidentes técnicos**.

---

## 📁 Estrutura do projeto

```text
devops-lab/
├── site/
│   ├── index.html
│   └── Dockerfile
│
├── terraform/
│   └── aws/
│       └── static-site/
│
├── app/api/
├── docker-compose.yml
├── .github/workflows/deploy.yml
│
├── docs/
│   ├── storageclass.md
│   ├── troubleshooting/
│   └── troubleshooting-grafana.md
│
├── helm/
│   ├── grafana/
│   └── prometheus/
│
├── kubernetes/
│   ├── backend/
│   ├── config/
│   ├── frontend/
│   ├── ingress/
│   ├── namespace/
│   ├── storage/
│   └── tests/
│
scripts/
├── common/
│   ├── config.sh
│   └── functions.sh
├── 01-update-system.sh
├── 02-disable-swap.sh
├── 03-install-containerd.sh
├── 04-install-kubernetes.sh
├── 05-install-crictl.sh
├── 06-init-cluster.sh
├── 07-join-workers.sh
├── 08-validate-host.sh
└── status-lab.sh
│
├── .gitignore
└── README.md
```

---

## 📚 Formação e origem do projeto

O laboratório foi iniciado a partir dos estudos realizados no **curso 526 da 4Linux** e vem sendo expandido de forma independente conforme novos conteúdos são estudados.

O projeto acompanha minha evolução na área de DevOps e serve como ambiente para transformar conhecimentos teóricos em prática.

---

## 🚀 Próximos passos

O laboratório continuará sendo desenvolvido progressivamente.

Entre os próximos objetivos estão:

* evolução da observabilidade com Prometheus e Grafana;
* aprofundamento em Helm;
* Ansible;
* Rancher;
* Istio;
* Elasticsearch e Kibana.

Os próximos módulos serão adicionados conforme forem estudados e efetivamente implementados no laboratório.

---

## ⚠️ Observação

Este é um **projeto pessoal de estudo e prática**.

As configurações e recursos apresentados têm finalidade educacional e podem ser modificados conforme a evolução do laboratório.

Credenciais, tokens, Secrets e arquivos sensíveis utilizados no ambiente local **não são versionados no repositório**.
