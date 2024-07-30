#!/bin/bash

################################################################################
# Script para instalar dependências básicas
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script instala pacotes e ferramentas básicas necessárias para
#            a configuração do servidor.
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

log $BLUE "Iniciando a instalação das dependências básicas..."

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

# Configuração do firewall
log $YELLOW "Configurando o firewall para permitir tráfego nas portas 80, 443, 5810 e 5432..."
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5810/tcp
sudo ufw allow 5432/tcp

# Verificar o status do firewall
log $YELLOW "Verificando status do firewall..."
sudo ufw status

log $GREEN "Dependências básicas instaladas com sucesso."
