# Deploy Cognito com Terraform

Este repositório contém a configuração do Terraform para implantar um pool de usuários do Cognito na AWS.

[Desenho da arquitetura](https://drive.google.com/file/d/12gofNmXk8W2QnhxiFWCI4OmvVH6Vsgun/view?usp=drive_link)

## Pré-requisitos

- Terraform instalado em sua máquina
- Credenciais da AWS configuradas em sua máquina
- Um bucket S3 existente para armazenar o estado do Terraform

## Uso

1. Clone este repositório.
2. Certifique-se de que suas credenciais da AWS estejam configuradas corretamente.
3. Navegue até o diretório contendo o arquivo `cognito.tf`.
4. Execute `terraform init` para inicializar a configuração do Terraform.
5. Execute `terraform plan` para ver as alterações planejadas.
6. Execute `terraform apply` para aplicar as alterações e criar o pool de usuários do Cognito.

## Recursos

- **Pool de Usuários do Cognito:** `mikes-user-pool` - Um pool de usuários do Cognito com uma configuração mínima.
- **Cliente do Pool de Usuários do Cognito:** `mikes_app_client` - Um cliente do pool de usuários do Cognito para autenticação OAuth.
- **Função Lambda:** `mikes_lambda_pre_sign_up` - Uma função Lambda para processar pré-registros de usuários.

## Observações

- Certifique-se de substituir os valores necessários nos arquivos de configuração do Terraform, como `bucket`, `key`, `region`, `callback_urls`, `logout_urls`, etc.
- Certifique-se de configurar o bloco `provider` em `cognito.tf` com a região AWS correta.
- Este exemplo usa a versão 0.15.0 do Terraform, ajuste conforme necessário para versões mais recentes.
