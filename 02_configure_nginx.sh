#!/bin/bash

################################################################################
# Script para configurar o NGINX
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script configura o NGINX para redirecionar HTTP para HTTPS e
#            configurar proxy reverso.
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

log $BLUE "Iniciando a configuração do NGINX..."

# Verificar se o arquivo de configuração SSL existe
log $YELLOW "Verificando a existência do arquivo de configuração SSL..."
if [ ! -f "/etc/letsencrypt/options-ssl-nginx.conf" ]; then
    log $RED "Arquivo /etc/letsencrypt/options-ssl-nginx.conf não encontrado. Instalando ou reinstalando Certbot..."
    sudo apt-get install --reinstall certbot
fi

# Configurar NGINX para redirecionar HTTP para HTTPS
log $YELLOW "Configurando NGINX para redirecionar HTTP para HTTPS e configurar proxy reverso..."

# Configuração do NGINX para devcloud.top
log $YELLOW "Criando configuração para devcloud.top..."
cat <<EOF | sudo tee /etc/nginx/sites-available/devcloud.top
server {
    listen 80;
    listen [::]:80;
    server_name devcloud.top www.devcloud.top;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name devcloud.top www.devcloud.top;

    ssl_certificate /etc/letsencrypt/live/devcloud.top/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/devcloud.top/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /opt/devcloud/devcloud.top;

    index index.html index.htm index.nginx-debian.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Configuração do NGINX para api.devcloud.top
log $YELLOW "Criando configuração para api.devcloud.top..."
cat <<EOF | sudo tee /etc/nginx/sites-available/api.devcloud.top
server {
    listen 80;
    listen [::]:80;
    server_name api.devcloud.top;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name api.devcloud.top;

    ssl_certificate /etc/letsencrypt/live/api.devcloud.top/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.devcloud.top/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:5810;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Habilitar os sites e reiniciar o NGINX
log $YELLOW "Habilitando sites e testando configuração do NGINX..."
sudo ln -s /etc/nginx/sites-available/devcloud.top /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/api.devcloud.top /etc/nginx/sites-enabled/

log $YELLOW "Testando configuração do NGINX..."
sudo nginx -t

if [ $? -ne 0 ]; then
    log $RED "Erro na configuração do NGINX. Verifique os logs para mais detalhes."
    exit 1
fi

log $YELLOW "Reiniciando o NGINX..."
sudo systemctl restart nginx

# Verificar se o NGINX está em execução
log $YELLOW "Verificando status do NGINX..."
sudo systemctl status nginx

log $GREEN "NGINX configurado com sucesso."
