#!/bin/bash

################################################################################
# Script Principal para configuração do servidor e projeto
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script executa os scripts individuais para configurar o servidor,
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

# Caminho para os scripts individuais
INSTALL_SCRIPT="./01_install_dependencies.sh"
NGINX_SCRIPT="./02_configure_nginx.sh"
PROJECT_SCRIPT="./03_setup_project.sh"

# Verificar se os scripts existem e são executáveis
if [ ! -x "$INSTALL_SCRIPT" ] || [ ! -x "$NGINX_SCRIPT" ] || [ ! -x "$PROJECT_SCRIPT" ]; then
    log $RED "Um ou mais scripts necessários não foram encontrados ou não são executáveis."
    exit 1
fi

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
