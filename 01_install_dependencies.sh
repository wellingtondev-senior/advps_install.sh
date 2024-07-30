#!/bin/bash

################################################################################
# Script de Instalação de Dependências - Ubuntu 20.04
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script instala NGINX, Docker, Docker Compose, NVM, Node.js LTS,
#            PM2 e PostgreSQL em uma máquina Ubuntu 20.04.
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

log $BLUE "Iniciando a instalação das dependências..."

# Atualizar lista de pacotes e instalar dependências
log $YELLOW "Atualizando lista de pacotes e instalando dependências..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    ufw \
    nginx \
    docker.io \
    docker-compose

#  Configurar o Docker para iniciar automaticamente
# log $YELLOW "Configurando o Docker para iniciar automaticamente..."
# sudo systemctl enable docker --quiet
# sudo systemctl start docker --quiet

log $GREEN "Dependências instaladas e configuradas com sucesso."
