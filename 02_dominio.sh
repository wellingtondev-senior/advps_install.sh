#!/bin/bash

################################################################################
# Script de Configuração do NGINX
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script configura o NGINX para os domínios devcloud.top e 
#             api.devcloud.top, incluindo a configuração de SSL/TLS usando o Certbot.
################################################################################

# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

DOMINIO_FRONTEND='devcloud.top'
DOMINIO_API='api.devcloud.top'
SSL_CONFIG_URL="https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/options-ssl-nginx.conf"

# Função de log para imprimir mensagens com timestamps e cores
log() {
    local color=$1
    shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NC}"
}

log $BLUE "Iniciando a configuração do NGINX..."

# Função para baixar e substituir o arquivo de configuração SSL/TLS
fix_ssl_config() {
    local url=$1
    local dest=$2
    log $YELLOW "Baixando configuração SSL/TLS de: $url"
    curl -s -o "$dest" "$url"
    if [ $? -ne 0 ]; then
        log $RED "Erro ao baixar a configuração SSL/TLS de $url"
        exit 1
    fi
    log $GREEN "Configuração SSL/TLS baixada e substituída com sucesso."
}

# Verificar e corrigir o arquivo de opções SSL/TLS do Certbot
if [ ! -f "/etc/letsencrypt/options-ssl-nginx.conf" ] || ! grep -q "ssl_protocols" /etc/letsencrypt/options-ssl-nginx.conf; then
    log $RED "Arquivo /etc/letsencrypt/options-ssl-nginx.conf não encontrado ou corrompido. Baixando novamente..."
    sudo mkdir -p /etc/letsencrypt
    fix_ssl_config "$SSL_CONFIG_URL" "/etc/letsencrypt/options-ssl-nginx.conf"
fi

# Configuração do NGINX para o frontend e a API
NGINX_CONF_FRONTEND="/etc/nginx/sites-available/devcloud.top"
NGINX_CONF_API="/etc/nginx/sites-available/api.devcloud.top"

log $YELLOW "Configurando o NGINX para devcloud.top (frontend)..."
sudo tee "$NGINX_CONF_FRONTEND" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMINIO_FRONTEND;

    location / {
        root /opt/devcloud/devcloud.top;
        index index.html index.htm;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
}

server {
    listen 443 ssl;
    server_name $DOMINIO_FRONTEND;

    ssl_certificate /etc/letsencrypt/live/$DOMINIO_FRONTEND/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMINIO_FRONTEND/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /opt/devcloud/devcloud.top;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

log $YELLOW "Configurando o NGINX para api.devcloud.top (API)..."
sudo tee "$NGINX_CONF_API" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMINIO_API;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMINIO_API;

    ssl_certificate /etc/letsencrypt/live/$DOMINIO_API/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMINIO_API/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:5810;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Habilitar as configurações NGINX, removendo links simbólicos existentes se necessário
if [ -L /etc/nginx/sites-enabled/devcloud.top ]; then
    sudo rm /etc/nginx/sites-enabled/devcloud.top
fi
sudo ln -s /etc/nginx/sites-available/devcloud.top /etc/nginx/sites-enabled/

if [ -L /etc/nginx/sites-enabled/api.devcloud.top ]; then
    sudo rm /etc/nginx/sites-enabled/api.devcloud.top
fi
sudo ln -s /etc/nginx/sites-available/api.devcloud.top /etc/nginx/sites-enabled/

# Testar e reiniciar o NGINX
log $YELLOW "Testando e reiniciando o NGINX..."
sudo nginx -t
if [ $? -ne 0 ]; then
    log $RED "Erro na configuração do NGINX. Abortando."
    exit 1
fi

sudo systemctl restart nginx

log $GREEN "NGINX configurado e em execução com sucesso."
