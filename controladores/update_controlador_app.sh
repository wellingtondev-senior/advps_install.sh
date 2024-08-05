#!/bin/bash

# Função para exibir mensagem de erro e sair
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Navegar até o diretório do projeto
cd /home/devcloud/controlapp.devcloud.top || error_exit "Erro: Não foi possível acessar o diretório do projeto."

# Fazer pull do repositório Git
echo "Executando git pull..."
git pull || error_exit "Erro: Falha ao executar git pull."

# Instalar dependências do npm
echo "Executando npm install..."
npm install || error_exit "Erro: Falha ao executar npm install."

# Build do projeto
echo "Executando npm run build..."
npm run build || error_exit "Erro: Falha ao executar npm run build."

# Reiniciar a aplicação com pm2
echo "Reiniciando a aplicação com pm2..."
pm2 restart controlapp_devcloud || error_exit "Erro: Falha ao reiniciar a aplicação com pm2."

# Exibir logs da aplicação
echo "Exibindo logs da aplicação..."
pm2 log controlapp_devcloud || error_exit "Erro: Falha ao exibir os logs da aplicação com pm2."

echo "Script executado com sucesso!"
