#!/bin/bash

################################################################################
# Parte 4: Instalar NVM, Node.js LTS e PM2
################################################################################

# Cores para log
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # Sem cor

# Função de log para imprimir mensagens com timestamps e cores
log() {
    local color=$1
    shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NC}"
}

log $YELLOW "Instalando NVM, Node.js LTS e PM2..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

source ~/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"

log $YELLOW "Verificando instalações do NVM, Node.js e npm..."
command -v nvm
command -v node
command -v npm

log $YELLOW "Instalando a versão LTS do Node.js..."
nvm install --lts
nvm use --lts

log $YELLOW "Instalando PM2 globalmente..."
npm install -g pm2

log $YELLOW "Verificando instalação do PM2..."
command -v pm2

log $YELLOW "Configurando PM2 para iniciar automaticamente na inicialização do sistema..."
pm2 startup systemd -u $USER --hp $HOME
pm2 save

log $GREEN "NVM, Node.js LTS e PM2 instalados e configurados com sucesso."
