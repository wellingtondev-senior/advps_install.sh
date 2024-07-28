#!/bin/bash

################################################################################
# Script de Configuração de Servidor - Ubuntu 20.04
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script instala e configura NGINX, Docker e Docker Compose
#            em uma máquina Ubuntu 20.04. Ele inclui a atualização dos pacotes,
#            a adição de repositórios necessários, a instalação de dependências,
#            e a configuração de serviços para serem executados automaticamente.
################################################################################

# Função de log para imprimir mensagens com timestamps
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Iniciando a configuração do servidor..."

# Atualizar lista de pacotes e instalar dependências
log "Atualizando lista de pacotes e instalando dependências..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Adicionar chave GPG oficial do Docker
log "Adicionando chave GPG oficial do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionar repositório Docker
log "Adicionando repositório Docker..."
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Atualizar lista de pacotes novamente
log "Atualizando lista de pacotes novamente..."
sudo apt-get update

# Instalar Docker
log "Instalando Docker..."
sudo apt-get install -y docker-ce

# Adicionar usuário atual ao grupo Docker para executar comandos sem sudo
log "Adicionando usuário atual ao grupo Docker..."
sudo usermod -aG docker $USER

# Baixar a última versão estável do Docker Compose
log "Baixando a última versão estável do Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Dar permissão de execução para o Docker Compose
log "Dando permissão de execução para o Docker Compose..."
sudo chmod +x /usr/local/bin/docker-compose

# Verificar se o Docker e o Docker Compose foram instalados corretamente
log "Verificando se o Docker e o Docker Compose foram instalados corretamente..."
docker --version
docker-compose --version

log "Instalação do Docker e Docker Compose concluída com sucesso."
log "Você pode precisar sair e entrar novamente para aplicar as alterações do grupo Docker."

# Atualizar pacotes e instalar NGINX
log "Atualizando pacotes e instalando NGINX..."
sudo apt update
sudo apt install -y nginx

# Habilitar e iniciar o serviço NGINX
log "Habilitando e iniciando o serviço NGINX..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Exibir o status do serviço NGINX
log "Verificando o status do serviço NGINX..."
sudo systemctl status nginx

# Verificar a versão do NGINX
log "Verificando a versão do NGINX..."
nginx -v

# Verificar se o NGINX está escutando nas portas 80 e 443
log "Verificando se o NGINX está escutando nas portas 80 e 443..."
sudo netstat -tuln | grep ':80\|:443'

log "NGINX instalado e em execução com sucesso."
