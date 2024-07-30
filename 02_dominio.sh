#!/bin/bash

################################################################################
# Script de Instalação e Configuração do NGINX com Certbot e Cloudflare SSL
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script configura o NGINX para os domínios especificados, 
#             incluindo a instalação do Certbot e a configuração de SSL/TLS 
#             usando certificados Let's Encrypt e Cloudflare.
################################################################################

# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Variáveis Cloudflare
CLOUDFLARE_EMAIL="wrm.net@gmail.com"
CLOUDFLARE_API_KEY="45b7e2850db3403a6b8ae0e1b85f042c0a80e"
DOMAIN="devcloud.top"
CLOUDFLARE_ZONE_ID="a102eaf236a81cd20d3a6e2c7c81d955"

# Variáveis do NGINX
DOMINIO_FRONTEND='devcloud.top'
DOMINIO_API='api.devcloud.top'
SSL_CONFIG_URL="https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/options-ssl-nginx.conf"

# Função de log para imprimir mensagens com timestamps e cores
log() {
    local color=$1
    shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NC}"
}

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

# Função para instalar dependências
install_dependencies() {
    log $BLUE "Instalando dependências..."
    apt-get update
    apt-get install -y curl jq nginx python3-certbot-nginx
    if [ $? -ne 0 ]; then
        log $RED "Erro ao instalar dependências. Abortando."
        exit 1
    fi
}

# Função para obter certificado do Cloudflare
get_cloudflare_cert() {
    log $BLUE "Obtendo certificado SSL do Cloudflare..."
    CERT_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/ssl/certificates" \
      -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
      -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
      -H "Content-Type: application/json")

    CERTIFICATE=$(echo $CERT_RESPONSE | jq -r '.result[0].certificate')
    PRIVATE_KEY=$(echo $CERT_RESPONSE | jq -r '.result[0].private_key')

    if [[ -z "$CERTIFICATE" || -z "$PRIVATE_KEY" ]]; then
      log $RED "Falha ao obter o certificado SSL do Cloudflare."
      exit 1
    fi

    echo "$CERTIFICATE" > /etc/ssl/certs/cloudflare.crt
    echo "$PRIVATE_KEY" > /etc/ssl/private/cloudflare.key
    chmod 600 /etc/ssl/private/cloudflare.key
}

# Função para configurar o NGINX
configure_nginx() {
    log $YELLOW "Configurando o NGINX para $DOMINIO_FRONTEND e $DOMINIO_API..."

    sudo tee /etc/nginx/sites-available/devcloud.top > /dev/null <<EOF
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

    sudo tee /etc/nginx/sites-available/api.devcloud.top > /dev/null <<EOF
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

    # Habilitar as configurações NGINX
    sudo ln -s /etc/nginx/sites-available/devcloud.top /etc/nginx/sites-enabled/
    sudo ln -s /etc/nginx/sites-available/api.devcloud.top /etc/nginx/sites-enabled/
}

# Função para reiniciar o NGINX
restart_nginx() {
    log $YELLOW "Testando e reiniciando o NGINX..."
    sudo nginx -t
    if [ $? -ne 0 ]; then
        log $RED "Erro na configuração do NGINX. Abortando."
        exit 1
    fi

    sudo systemctl restart nginx
}

# Main
install_dependencies

# Obter e instalar certificados do Cloudflare
get_cloudflare_cert

# Corrigir e garantir a configuração SSL/TLS
fix_ssl_config "$SSL_CONFIG_URL" "/etc/letsencrypt/options-ssl-nginx.conf"

# Configurar NGINX
configure_nginx

# Reiniciar NGINX
restart_nginx

log $GREEN "NGINX configurado e em execução com sucesso."
