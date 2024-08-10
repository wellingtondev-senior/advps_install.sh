#!/bin/bash

# Defina o caminho e o e-mail
KEY_PATH="$HOME/.ssh/id_rsa"
EMAIL="seu_email@example.com"

# Verifique se o diretório ~/.ssh existe
if [ ! -d "$HOME/.ssh" ]; then
    echo "Diretório ~/.ssh não existe. Criando o diretório..."
    mkdir -p "$HOME/.ssh"
fi

# Gere o par de chaves SSH, sobrescrevendo qualquer chave existente
ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f "$KEY_PATH" -N "" -q <<< "y"

# Informe o usuário sobre a chave gerada
echo "Chave SSH gerada com sucesso!"
echo "Chave privada: $KEY_PATH"
echo "Chave pública: ${KEY_PATH}.pub"

# Exiba a chave pública
echo "Conteúdo da chave pública:"
cat "${KEY_PATH}.pub"
