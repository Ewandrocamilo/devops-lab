# DevOps Lab

Projeto de portfólio que reúne um dashboard estático e práticas de infraestrutura, automação e operação. O dashboard está publicado na AWS e documenta a arquitetura, as decisões técnicas, o pipeline e aprendizados do laboratório.

**Site:** [d352ryjwl42oc2.cloudfront.net](https://d352ryjwl42oc2.cloudfront.net)

## Arquitetura atual

```text
Navegador → CloudFront → bucket S3 privado
                         ↑
GitHub Actions (OIDC) ───┘ publica site/index.html e invalida o cache
```

O site não faz consultas à API, ao PostgreSQL ou a um cluster Kubernetes. O bucket só permite leitura pelo CloudFront. O GitHub Actions recebe acesso temporário à AWS por OIDC.

O dashboard apresenta Overview, Architecture, Infrastructure, CI/CD, Technical Decisions e Lessons Learned.

## Executar a prévia local

Com Docker Compose:

```bash
docker compose up --build -d dashboard
```

Abra [http://localhost:8081](http://localhost:8081). Esse comando inicia somente o servidor do site estático. A API Flask e o PostgreSQL definidos no Compose são exercícios locais opcionais e não fazem parte da hospedagem do dashboard.

## Deploy e infraestrutura AWS

O workflow em `.github/workflows/deploy.yml` publica o site quando há alterações em `site/` ou no próprio workflow em `main`. Também pode ser iniciado manualmente pela aba **Actions** do GitHub.

O repositório configura duas variáveis de Actions:

- `DASHBOARD_S3_BUCKET`
- `DASHBOARD_CLOUDFRONT_DISTRIBUTION_ID`

A infraestrutura atual do site está isolada em `terraform/aws/static-site`: bucket privado, CloudFront com Origin Access Control e permissão de deploy do GitHub Actions. Os outputs do Terraform incluem o nome do bucket, o ID da distribuição e o domínio público.

## Laboratório Kubernetes (opcional)

As pastas abaixo preservam exercícios independentes feitos durante a evolução do projeto. Elas documentam conhecimento prático, mas não são dependências do site publicado nem indicam que exista um cluster ativo:

- `kubernetes/`: manifests Kustomize para workloads de laboratório, configuração, armazenamento e ingress;
- `helm/`: valores personalizados para Prometheus e Grafana;
- `scripts/`: preparação de hosts Ubuntu, instalação do containerd e Kubernetes, inicialização e validação do cluster;
- `docs/`: registros de troubleshooting de armazenamento e Grafana.

Os manifests de frontend e backend usam imagens de demonstração. A API Flask em `app/api` e o PostgreSQL do Docker Compose também são uma prática local separada.

## Terraform EC2 legado

`terraform/aws` é um stack EC2 anterior e permanece separado do site estático. Não é necessário para servir o dashboard. Antes de aplicar mudanças nesse diretório, confira o plano: ele pode criar ou alterar recursos AWS que geram cobrança. Remover os arquivos do repositório não desligaria recursos que já estejam ativos.

## Segurança

O bucket do site não é público. Arquivos `.env`, estado Terraform (`*.tfstate`) e variáveis locais não devem ser versionados. Use `.env.example` apenas como referência para o stack local.
