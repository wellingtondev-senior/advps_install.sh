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

log $BLUE "Iniciando a configuração do BACKEND..."

# Configuração do diretório do projeto e execução do Docker
PROJECT_DIR="/opt/devcloud/api.devcloud.top"
REPO_URL="git@github.com:wellingtondev-senior/api.wellingtondev.com.git"

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

# Função para verificar se a porta está disponível
check_port() {
    local port=$1
    nc -z localhost $port > /dev/null 2>&1
    return $?
}

# Selecionar uma porta dinâmica disponível
PORT=$(shuf -i 3000-9000 -n 1)

# Verificar se a porta está disponível
while ! check_port $PORT; do
    log $YELLOW "Porta $PORT está em uso, selecionando outra porta..."
    PORT=$(shuf -i 3000-9000 -n 1)
done

log $YELLOW "Porta dinâmica selecionada: $PORT"

# Atualizar o arquivo de configuração para usar a porta dinâmica
# Supondo que você tenha um arquivo .env para definir variáveis de ambiente
echo "PORT=$PORT" > .env

log $YELLOW "Iniciando o projeto com PM2..."
# Iniciar o projeto com PM2 e definir o nome da aplicação como "api"
pm2 start npm --name api_devcloud -- run start:prod

# Instalar e configurar o firewall para permitir a porta dinâmica
log $YELLOW "Instalando e configurando o firewall..."

# Permitir a porta dinâmica no firewall
sudo ufw allow $PORT/tcp

# Habilitar o firewall, se ainda não estiver habilitado
sudo ufw enable

# Mostrar o status do firewall
sudo ufw status

log $GREEN "Configuração concluída com sucesso!"
