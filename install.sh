#!/bin/bash

# Atualizar lista de pacotes e instalar dependências
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Adicionar chave GPG oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionar repositório Docker
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Atualizar lista de pacotes novamente
sudo apt-get update

# Instalar Docker
sudo apt-get install -y docker-ce

# Adicionar usuário atual ao grupo Docker para executar comandos sem sudo
sudo usermod -aG docker $USER

# Baixar a última versão estável do Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Dar permissão de execução para o Docker Compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar se o Docker e o Docker Compose foram instalados corretamente
docker --version
docker-compose --version

echo "Instalação do Docker e Docker Compose concluída com sucesso."
echo "Você pode precisar sair e entrar novamente para aplicar as alterações do grupo Docker."

