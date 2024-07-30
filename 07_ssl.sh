#!/bin/bash

################################################################################
# Script de Instalação do Certbot
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script instala o Certbot e o plugin NGINX para a configuração
#             de SSL/TLS usando certificados Let's Encrypt.
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

log $BLUE "Iniciando a instalação do Certbot e do plugin NGINX..."

# Atualizar a lista de pacotes
log $YELLOW "Atualizando a lista de pacotes..."
sudo apt update
if [ $? -ne 0 ]; then
    log $RED "Erro ao atualizar a lista de pacotes. Abortando."
    exit 1
fi

# Instalar Certbot e o plugin NGINX
log $YELLOW "Instalando Certbot e o plugin NGINX..."
sudo apt install -y certbot python3-certbot-nginx
if [ $? -ne 0 ]; then
    log $RED "Erro ao instalar o Certbot e o plugin NGINX. Abortando."
    exit 1
fi

# Gerar a configuração padrão do SSL/TLS (se ainda não existir)
log $YELLOW "Gerando configuração padrão do SSL/TLS..."
if [ ! -f "/etc/letsencrypt/options-ssl-nginx.conf" ]; then
    sudo mkdir -p /etc/letsencrypt
    sudo curl -o /etc/letsencrypt/options-ssl-nginx.conf https://ssl-config.mozilla.org/ffdhe2048.pem
    if [ $? -ne 0 ]; then
        log $RED "Erro ao baixar a configuração padrão do SSL/TLS. Abortando."
        exit 1
    fi
fi

# Gerar parâmetros DH (se ainda não existir)
log $YELLOW "Gerando parâmetros DH..."
if [ ! -f "/etc/letsencrypt/ssl-dhparams.pem" ]; then
    sudo openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
    if [ $? -ne 0 ]; then
        log $RED "Erro ao gerar os parâmetros DH. Abortando."
        exit 1
    fi
fi

log $GREEN "Certbot e plugin NGINX instalados e configurados com sucesso."
