#!/bin/bash

################################################################################
# Script de Configuração de Servidor - Ubuntu 20.04
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script instala e configura NGINX, Docker e Docker Compose,
#            além do NVM, Node.js LTS e PM2 em uma máquina Ubuntu 20.04. 
#            Inclui a atualização dos pacotes, a adição de repositórios necessários,
#            a instalação de dependências e a configuração de serviços para serem 
#            executados automaticamente.
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

log $BLUE "Iniciando a configuração do servidor..."

# Atualizar lista de pacotes e instalar dependências
log $YELLOW "Atualizando lista de pacotes e instalando dependências..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    ufw

# Atualizar pacotes e instalar NGINX
log $YELLOW "Atualizando pacotes e instalando NGINX..."
sudo apt-get install -y nginx

# Habilitar e iniciar o serviço NGINX
log $YELLOW "Habilitando e iniciando o serviço NGINX..."
sudo systemctl enable nginx --quiet
sudo systemctl start nginx --quiet

# Verificar se o NGINX está escutando nas portas 80 e 443
log $YELLOW "Verificando se o NGINX está escutando nas portas 80 e 443..."
sudo netstat -tuln | grep ':80\|:443'

log $GREEN "NGINX instalado e em execução com sucesso."

# Configuração do diretório do projeto e execução do Docker
PROJECT_DIR="/opt/devcloud.com"
REPO_URL="git@github.com:wellingtondev-senior/api.wellingtondev.com.git"

# Criar o diretório do projeto e clonar o repositório
log $YELLOW "Criando o diretório do projeto e clonando o repositório..."
sudo mkdir -p $PROJECT_DIR
sudo git clone $REPO_URL $PROJECT_DIR

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

# Instalar a versão LTS do Node.js
log $YELLOW "Instalando a versão LTS do Node.js..."
nvm install --lts

# Instalar PM2 globalmente
log $YELLOW "Instalando PM2 globalmente..."
npm install -g pm2

# Configurar PM2 para iniciar automaticamente na inicialização do sistema
log $YELLOW "Configurando PM2 para iniciar automaticamente na inicialização do sistema..."
pm2 startup systemd -u $USER --hp $HOME
pm2 save

log $GREEN "NVM, Node.js LTS e PM2 instalados e configurados com sucesso."

# Instalar dependências e construir o projeto
log $YELLOW "Instalando dependências do projeto..."
npm install

log $YELLOW "Construindo o projeto..."
npm run build

log $YELLOW "Iniciando o projeto com PM2..."
# Iniciar o projeto com PM2 e definir o nome da aplicação como "app"
pm2 start npm --name "app" -- start

# Salvar o estado do PM2
pm2 save



# Configurar firewall
log $YELLOW "Configurando o firewall para permitir tráfego nas portas 80, 443 e 5810..."
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5810/tcp
sudo ufw --force enable

log $GREEN "Firewall configurado. Portas 80, 443 e 5810 estão abertas."
