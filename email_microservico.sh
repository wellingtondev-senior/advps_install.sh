#!/bin/bash

################################################################################
# Script para configurar o projeto
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script configura o projeto, instala Node.js, PM2, Docker e
#            Docker Compose, e finaliza a configuração.
################################################################################

# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor
IP=$(curl -s https://ipinfo.io/ip)

# Exibe o IP (opcional)

# Função de log para imprimir mensagens com timestamps e cores
log() {
    local color=$1
    shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NC}"
}

log $BLUE "Iniciando a configuração do BACKEND..."

# Configuração do diretório do projeto e execução do Docker
PROJECT_DIR="/home/devcloud/email.devcloud.top"
REPO_URL="git@github.com:wellingtondev-senior/email.devcloud.top.git"

# Criar o diretório do projeto e clonar o repositório
log $YELLOW "Criando o diretório do projeto e clonando o repositório..."
sudo mkdir -p $PROJECT_DIR
sudo git clone $REPO_URL $PROJECT_DIR

# Garantir que o diretório do projeto pertença ao usuário atual
sudo chown -R $USER:$USER $PROJECT_DIR

# Entrar no diretório do projeto
log $YELLOW "Entrando no diretório do projeto..."
cd $PROJECT_DIR

# Verificar se o arquivo package.json existe
if [ ! -f "$PROJECT_DIR/package.json" ]; then
    log $RED "Erro: O arquivo package.json não foi encontrado no diretório $PROJECT_DIR."
    exit 1
fi

# Instalar dependências e construir o projeto
log $YELLOW "Instalando dependências do projeto..."
npm install

log $YELLOW "Construindo o projeto..."
npm run build



# Verificar se a porta está disponível


# Atualizar o arquivo de configuração para usar a porta dinâmica
# Supondo que você tenha um arquivo .env para definir variáveis de ambiente

log $YELLOW "Iniciando o projeto com PM2..."
# Iniciar o projeto com PM2 e definir o nome da aplicação como "api"
pm2 start npm --name email_devcloud -- run start:prod

# Instalar e configurar o firewall para permitir a porta dinâmica
log $YELLOW "Instalando e configurando o firewall..."

yes | sudo ufw enable
# Permitir a porta dinâmica no firewall
sudo ufw allow 58552/tcp

# Habilitar o firewall, se ainda não estiver habilitado

# Mostrar o status do firewall
sudo ufw status

log $GREEN "Configuração concluída com sucesso!"

# Finalizar
 log $GREEN "###########################################################"
 log $GREEN "Aplicação API:"
 log $GREEN "Acesse a API em: http://$IP:58552"
 log $GREEN "###########################################################"