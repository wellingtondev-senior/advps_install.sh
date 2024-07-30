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

# Função de log para imprimir mensagens com timestamps e cores
log() {
    local color=$1
    shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NC}"
}

log $BLUE "Iniciando a configuração do FRONTEND..."

# Configuração do diretório do projeto e execução do Docker
PROJECT_DIR="/opt/devcloud/devcloud.top"
REPO_URL="git@github.com:wellingtondev-senior/devcloud.top.git"

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

log $YELLOW "Iniciando o projeto com PM2..."
# Iniciar o projeto com PM2 e definir o nome da aplicação como "api"
pm2 start npm --name devcloud --  start

# Finalizar
# log $GREEN "Configuração concluída. Credenciais de acesso padrão:"
# log $GREEN "PostgreSQL:"
# log $GREEN "  Username: postgres"
# log $GREEN "  Password: admin#master23451"
# log $GREEN "Aplicação:"
# log $GREEN "  Username: master"
# log $GREEN "  Password: master"
# log $GREEN "Acesse a aplicação em: https://devcloud.top"
# log $GREEN "Acesse a API em: https://api.devcloud.top"
# log $GREEN "Script de configuração concluído com sucesso."
