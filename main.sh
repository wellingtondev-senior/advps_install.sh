#!/bin/bash
# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
SKY='\033[48;0;33m'
NC='\033[0m' # Sem cor
IP=$(curl -s https://ipinfo.io/ip)

# Função de log para imprimir mensagens com timestamps e cores
log() {
    local color=$1
    shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NC}"
}

log $SKY "################################################################################"
log $SKY "#                                                                              #"
log $SKY "#                           SCRIPT PRINCIPAL PARA CONFIGURAÇÃO                 #"
log $SKY "#                        DO SERVIDOR E DO PROJETO                              #"
log $SKY "#                                                                              #"
log $SKY "# Autor: Wellington Ramos                                                      #"
log $SKY "# whats: +5521982349912                                                        #"
log $SKY "# Data: 07/2024                                                                #"
log $SKY "# Descrição: Este script baixa e executa scripts individuais                   #"
log $SKY "#              para configurar o servidor, o NGINX e o projeto.                #"
log $SKY "#                                                                              #"
log $SKY "################################################################################"

# URLs para os scripts individuais
INSTALL_DEPENDENCIAS_URL="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/install_dependencies.sh"
INSTALL_NODE_PM2_URL="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/install_nvm_node_pm2.sh"
API_URL="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/api.sh"
FRONTEND_URL="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/frontend.sh"
INSTALL_POSTGRES_URL="https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/install_postgresql.sh"

# Caminho para os scripts temporários
INSTALL_SCRIPT="./install_dependencies.sh"
INSTALL_NODE_PM2_SCRIPT="./install_nvm_node_pm2.sh"
API_SCRIPT="./api.sh"
FRONTEND_SCRIPT="./frontend.sh"
INSTALL_POSTGRES_SCRIPT="./install_postgresql.sh"

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
download_script "$INSTALL_DEPENDENCIAS_URL" "$INSTALL_SCRIPT"
download_script "$INSTALL_NODE_PM2_URL" "$INSTALL_NODE_PM2_SCRIPT"
download_script "$API_URL" "$API_SCRIPT"
download_script "$FRONTEND_URL" "$FRONTEND_SCRIPT"
download_script "$INSTALL_POSTGRES_URL" "$INSTALL_POSTGRES_SCRIPT"


# Executar o script de instalação das dependências
log $YELLOW "Executando o script de instalação das dependências..."
bash "$INSTALL_SCRIPT"
if [ $? -ne 0 ]; then
    log $RED "Erro ao executar o script de instalação das dependências. Abortando."
    exit 1
fi



# Executar o script de instalação do Node.js e PM2
log $YELLOW "Executando o script de instalação do Node.js e PM2..."
bash "$INSTALL_NODE_PM2_SCRIPT"
if [ $? -ne 0 ]; then
    log $RED "Erro ao executar o script de instalação do Node.js e PM2. Abortando."
    exit 1
fi

# Executar o script de instalação do PostgreSQL
log $YELLOW "Executando o script de instalação do PostgreSQL..."
bash "$INSTALL_POSTGRES_SCRIPT"
if [ $? -ne 0 ]; then
    log $RED "Erro ao executar o script de instalação do PostgreSQL. Abortando."
    exit 1
fi

# Executar o script de configuração da API
log $YELLOW "Executando o script de configuração da API..."
bash "$API_SCRIPT"
if [ $? -ne 0 ]; then
    log $RED "Erro ao executar o script de configuração da API. Abortando."
    exit 1
fi

# Executar o script de configuração do Frontend
log $YELLOW "Executando o script de configuração do Frontend..."
bash "$FRONTEND_SCRIPT"
if [ $? -ne 0 ]; then
    log $RED "Erro ao executar o script de configuração do Frontend. Abortando."
    exit 1
fi


# Mensagens de log
log $GREEN "#############################################################################"
log $GREEN "#                                                                           #"
log $GREEN "#   Todos os scripts foram executados com sucesso. Configuração concluída.  #"
log $GREEN "#                                                                           #"
log $GREEN "#############################################################################"
log $GREEN "#                                                                           #"
log $GREEN "#   Configuração concluída. Credenciais de acesso padrão:                   #"
log $GREEN "#                                                                           #"
log $GREEN "#############################################################################"
log $GREEN "#                                                                           #"
log $GREEN "#   PostgreSQL:                                                             #"
log $GREEN "#   Username: postgres                                                      #"
log $GREEN "#   Password: admin#master23451                                             #"
log $GREEN "#                                                                           #"
log $GREEN "#############################################################################"
log $GREEN "#                                                                           #"
log $GREEN "#   Aplicação:                                                              #"
log $GREEN "#                                                                           #"
log $GREEN "#   Username: master                                                        #"
log $GREEN "#   Password: master                                                        #"
log $GREEN "#                                                                           #"
log $GREEN "#############################################################################"
log $GREEN "#                                                                           #"
log $GREEN "#   Acesse a aplicação em: http://$IP:3999                                  #"
log $GREEN "#   Acesse a API em: http://$IP:58551                                       #"
log $GREEN "#                                                                           #"
log $GREEN "#############################################################################"
log $GREEN "#                                                                           #"
log $GREEN "#   Script de configuração concluído com sucesso.                           #"
log $GREEN "#                                                                           #"
log $GREEN "#############################################################################"
