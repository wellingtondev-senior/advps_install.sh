#!/bin/bash

################################################################################
# Script de Configuração de Servidor - Ubuntu 20.04
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script instala e configura NGINX, Docker e Docker Compose
#            em uma máquina Ubuntu 20.04. Ele inclui a atualização dos pacotes,
#            a adição de repositórios necessários, a instalação de dependências,
#            e a configuração de serviços para serem executados automaticamente.
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
    git

# Adicionar chave GPG oficial do Docker
log $YELLOW "Adicionando chave GPG oficial do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionar repositório Docker
log $YELLOW "Adicionando repositório Docker..."
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Atualizar lista de pacotes novamente
log $YELLOW "Atualizando lista de pacotes novamente..."
sudo apt-get update

# Instalar Docker
log $YELLOW "Instalando Docker..."
sudo apt-get install -y docker-ce

# Adicionar usuário atual ao grupo Docker para executar comandos sem sudo
log $YELLOW "Adicionando usuário atual ao grupo Docker..."
sudo usermod -aG docker $USER

# Baixar a última versão estável do Docker Compose
log $YELLOW "Baixando a última versão estável do Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Dar permissão de execução para o Docker Compose
log $YELLOW "Dando permissão de execução para o Docker Compose..."
sudo chmod +x /usr/local/bin/docker-compose

# Verificar se o Docker e o Docker Compose foram instalados corretamente
log $GREEN "Verificando se o Docker e o Docker Compose foram instalados corretamente..."
docker --version
docker-compose --version

log $GREEN "Instalação do Docker e Docker Compose concluída com sucesso."
log $GREEN "Você pode precisar sair e entrar novamente para aplicar as alterações do grupo Docker."

# Atualizar pacotes e instalar NGINX
log $YELLOW "Atualizando pacotes e instalando NGINX..."
sudo apt update
sudo apt install -y nginx

# Habilitar e iniciar o serviço NGINX
log $YELLOW "Habilitando e iniciando o serviço NGINX..."
sudo systemctl enable nginx
sudo systemctl start nginx





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

# Construir e executar os containers usando Docker Compose
log $YELLOW "Construindo e iniciando containers com Docker Compose..."
sudo docker-compose up --build -d

# Verificar se os containers estão em execução
log $GREEN "Verificando se os containers estão em execução..."
sudo docker ps

log $GREEN "Projeto configurado e containers em execução com sucesso."
