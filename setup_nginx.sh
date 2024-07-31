#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root"
  exit
fi

# Atualiza a lista de pacotes
echo "Atualizando lista de pacotes..."
apt-get update

# Instala o NGINX
echo "Instalando NGINX..."
apt-get install -y nginx

# Cria um arquivo de configuração padrão
echo "Configurando NGINX..."
cat <<EOL > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Testa a configuração do NGINX para garantir que não há erros
echo "Testando configuração do NGINX..."
nginx -t

# Reinicia o serviço NGINX para aplicar as mudanças
echo "Reiniciando NGINX..."
systemctl restart nginx

# Habilita o serviço NGINX para iniciar automaticamente na inicialização do sistema
echo "Habilitando NGINX na inicialização do sistema..."
systemctl enable nginx

sudo ufw allow 80/tcp


echo "Configuração do NGINX concluída!"
