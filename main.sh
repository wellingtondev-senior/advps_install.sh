#!/bin/bash

################################################################################
# Script Principal para configuração do servidor e projeto
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script baixa e executa os scripts individuais para configurar o servidor,
#            o NGINX e o projeto.
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

log $BLUE "Iniciando o script principal para configuração do servidor e projeto..."

# URLs para os scripts individuais
INSTALL_DEPENDENCIAS="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/01_install_dependencies.sh"
CONFIGUAR_DOMINIO="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/02_configurar_dominio.sh"
NODE_PM2_INSTALL="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/03_install_nvm_node_pm2.sh"
SETUP_API="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/04_setup_api.sh"
SETUP_FRONTEND="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/05_setup_frontend.sh"
SETUP_POSTGRES="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/06_install_postgresql.sh"

# Caminho para os scripts temporários
INSTALL_SCRIPT="./01_install_dependencies.sh"
NGINX_SCRIPT="./02_configure_nginx.sh"
PROJECT_SCRIPT="./03_setup_project.sh"

# Função para baixar e verificar os scripts
download_script() {
    local url=$1
    local dest=$2
    log $YELLOW "Baixando script de: $url"
    curl -s -o "$dest" "$url"
    if [ $? -ne 0 ]; then
        log $RED "Erro ao baixar o script de $url"
        exit 1
    fi
    chmod +x "$dest"
}

# Baixar e executar os scripts individuais
download_script "$INSTALL_SCRIPT_URL" "$INSTALL_SCRIPT"
download_script "$NGINX_SCRIPT_URL" "$NGINX_SCRIPT"
download_script "$PROJECT_SCRIPT_URL" "$PROJECT_SCRIPT"

# Executar o script de instalação das dependências
log $YELLOW "Executando o script de instalação das dependências..."
bash "$INSTALL_SCRIPT"
if [ $? -ne 0 ]; then
    log $RED "Erro ao executar o script de instalação das dependências. Abortando."
    exit 1
fi

# Executar o script de configuração do NGINX
log $YELLOW "Executando o script de configuração do NGINX..."
bash "$NGINX_SCRIPT"
if [ $? -ne 0 ]; then
    log $RED "Erro ao executar o script de configuração do NGINX. Abortando."
    exit 1
fi

# Executar o script de configuração do projeto
log $YELLOW "Executando o script de configuração do projeto..."
bash "$PROJECT_SCRIPT"
if [ $? -ne 0 ]; then
    log $RED "Erro ao executar o script de configuração do projeto. Abortando."
    exit 1
fi

log $GREEN "Todos os scripts foram executados com sucesso. Configuração concluída."
log $GREEN "#############################################################################"
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
log $GREEN "#############################################################################"
