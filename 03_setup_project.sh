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

log $BLUE "Iniciando a configuração do projeto..."

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

# Instalar NVM, Node.js LTS e PM2
log $YELLOW "Instalando NVM, Node.js LTS e PM2..."

# Baixar e instalar o NVM
log $YELLOW "Baixando e instalando NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# Carregar o NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Adicionar NVM ao .bashrc para garantir que esteja disponível em novos terminais
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# Carregar o NVM no shell atual
source ~/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Adicionar Node.js e npm ao PATH
export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"

# Verificar se nvm, node e npm estão instalados corretamente
log $YELLOW "Verificando instalações do NVM, Node.js e npm..."
command -v nvm
command -v node
command -v npm

# Instalar a versão LTS do Node.js
log $YELLOW "Instalando a versão LTS do Node.js..."
nvm install --lts
nvm use --lts

# Instalar PM2 globalmente
log $YELLOW "Instalando PM2 globalmente..."
npm install -g pm2

# Verificar se pm2 está instalado corretamente
log $YELLOW "Verificando instalação do PM2..."
command -v pm2

# Configurar PM2 para iniciar automaticamente na inicialização do sistema
log $YELLOW "Configurando PM2 para iniciar automaticamente na inicialização do sistema..."
pm2 startup systemd -u $USER --hp $HOME
pm2 save

log $GREEN "NVM, Node.js LTS e PM2 instalados e configurados com sucesso."

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
pm2 start dist/main.js --name "api" --watch

# Configurar Docker
log $YELLOW "Instalando Docker e Docker Compose..."
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# Configurar e iniciar o Docker Compose
log $YELLOW "Configurando e iniciando o Docker Compose..."
# Criar arquivo docker-compose.yml
cat <<EOF | sudo tee /opt/devcloud/docker-compose.yml
version: '3'
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./data:/usr/share/nginx/html
      - ./conf.d:/etc/nginx/conf.d
    networks:
      - devcloud_network

  api:
    image: your-docker-image
    ports:
      - "5810:5810"
    networks:
      - devcloud_network

networks:
  devcloud_network:
    driver: bridge
EOF

# Iniciar os serviços Docker
sudo docker-compose -f /opt/devcloud/docker-compose.yml up -d

# Finalizar
log $GREEN "Configuração concluída. Credenciais de acesso padrão:"
log $GREEN "PostgreSQL:"
log $GREEN "  Username: postgres"
log $GREEN "  Password: admin#master23451"
log $GREEN "Aplicação:"
log $GREEN "  Username: master"
log $GREEN "  Password: master"
log $GREEN "Acesse a aplicação em: https://devcloud.top"
log $GREEN "Acesse a API em: https://api.devcloud.top"
log $GREEN "Script de configuração concluído com sucesso."
