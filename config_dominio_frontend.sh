#!/bin/bash

################################################################################
# Script de Instalação e Configuração do NGINX
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script configura o NGINX para o domínio especificado, 
#             redirecionando para a aplicação frontend sem configurar SSL.
################################################################################

# Ativar o modo de falha rápida
set -e

# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Variáveis do NGINX
DOMINIO_FRONTEND='devcloud.top'

# Função de log para imprimir mensagens com timestamps e cores
log() {
    local color=$1
    shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NC}"
}

# Função para instalar dependências
install_dependencies() {
    log $BLUE "Instalando dependências..."
    apt-get update
    apt-get install -y curl jq nginx
    log $GREEN "Dependências instaladas com sucesso."
}

# Função para configurar o NGINX
configure_nginx() {
    log $YELLOW "Configurando o NGINX para $DOMINIO_FRONTEND..."

    cat <<EOF | sudo tee /etc/nginx/sites-available/devcloud.top > /dev/null
server {
    listen 80;
    server_name $DOMINIO_FRONTEND;

    location / {
        proxy_pass http://localhost:3999;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    sudo ln -sf /etc/nginx/sites-available/devcloud.top /etc/nginx/sites-enabled/
    log $GREEN "Configuração do NGINX concluída."
}

# Função para reiniciar o NGINX
restart_nginx() {
    log $YELLOW "Testando e reiniciando o NGINX..."
    sudo nginx -t
    sudo systemctl restart nginx
    log $GREEN "NGINX reiniciado com sucesso."
}

# Main
install_dependencies
configure_nginx
restart_nginx

log $GREEN "NGINX configurado e em execução com sucesso."
