## Azure Architecture
# Construindo Arquitetura no Azure com Terraform

Este projeto demonstra como construir uma arquitetura básica no Microsoft Azure utilizando Terraform. A arquitetura inclui:

- Um grupo de recursos (Resource Group)
- Uma rede virtual (VNet) com uma sub-rede
- Uma máquina virtual Linux (VM)
- Um endereço IP público e uma interface de rede
- Grupo de Segurança de Rede (NSG): Proteção adicional para a máquina virtual, permitindo apenas tráfego SSH (porta 22).
- Servidor PostgreSQL: Implementação de um servidor de banco de dados PostgreSQL.
- Banco de Dados PostgreSQL: Configuração de um banco de dados com charset e collation definidos.
- Regras de Firewall para PostgreSQL: Acesso ao banco de dados por meio de regras de firewall que permitem tráfego de IPs externos.
- Configuração de SSL: Implementação de SSL enforcement no servidor PostgreSQL para garantir conexões seguras.

## Requisitos Necessários

Antes de iniciar, certifique-se de ter os seguintes itens:

- Conta no [Microsoft Azure](https://portal.azure.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) instalada e configurada
- [Terraform](https://www.terraform.io/downloads.html) instalado na sua máquina
- Permissões para criar recursos no Azure

### Instalação da Azure CLI

Caso não tenha instalado a Azure CLI, utilize o seguinte comando:

**Para rodar no Windows:**
```bash
winget install Microsoft.AzureCLI
```

**Para rodar no Linux:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Para rodar no MacOS:**
```bash
brew update && brew install azure-cli
```

Em seguida faça o login na Azure utilizando:

```bash
az login
```

Isso abrirá o navegador para autenticação ou pedirá suas credenciais.

# Configuração da assinatura (Este passo é opcional)
Caso você tenha múltiplas assinaturas na Azure, selecione a correta:

```bash
az account set --subscription "subscription-id"
```

# Estrutura do Projeto
```
AzureDatabase/
│
├──Infra/
│    └── main.tf
│    └── secrets.tfvars              //NÃO INCLUIR NO CONTROLE DE VERSÃO (utilizar .gitignore)
│    └── terraform.tfstate           //NÃO INCLUIR NO CONTROLE DE VERSÃO (utilizar .gitignore)
└── README.md
```

### Criação e execução do Terraform
Após a autenticação realizada anteriormente realize os seguintes passos:
1. Criar um arquivo `main.tf` (como este presente na pasta `infra`).
2. Iniciar o Terraform
3. Planejar a infra (gera um plano de execução, afim de verificar o que será criado)
4. Aplicar a configuração (neste passo, criará toda a arquitetura utilizando as variáveis de credenciais, visando a segurança)

### Inicializar o Terraform
```bash
terraform init
```

### Planejar a infra
```bash
terraform plan -var-file="secrets.tfvars"
```

### Aplicar a configuração
```bash
terraform apply -var-file="secrets.tfvars"
```

## Observações
- Não estarei utilizando o .gitignore neste repositório justamente por não estar utilizando alguma credencial válida, logo não há riscos. Quando utilizar no seu projeto use o .gitignore, desta forma as informações sensíveis não terão acesso público, ou seja, **Não deve ser incluído de forma alguma no controle de versão**.

- O arquivo .tfstate serve para armazenar o estado da infraestrutura provisionada, ele é gerado automaticamente e **Não deve ser incluído de forma alguma no controle de versão**, assim como o .tfvars