#!/bin/bash

# Verifica se as variáveis de ambiente PORT e DOMAIN estão definidas
if [ -z "$PORT" ] || [ -z "$DOMAIN" ]; then
  echo "As variáveis de ambiente PORT e DOMAIN devem ser definidas."
  echo "Exemplo: PORT=80 DOMAIN=example.com ./script.sh"
  exit 1
fi

# Caminho para o arquivo de configuração do NGINX
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

# Cria o conteúdo da configuração do NGINX
NGINX_CONF_CONTENT="
server {
    listen $PORT;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
"

# Cria o arquivo de configuração do NGINX
echo "$NGINX_CONF_CONTENT" > $NGINX_CONF

# Cria um link simbólico para habilitar a configuração
ln -s $NGINX_CONF /etc/nginx/sites-enabled/

# Testa a configuração do NGINX
nginx -t

# Se o teste for bem-sucedido, reinicia o NGINX
if [ $? -eq 0 ]; then
  echo "Configuração do NGINX está correta. Reiniciando o NGINX..."
  systemctl restart nginx
else
  echo "Erro na configuração do NGINX. Corrija os erros e tente novamente."
  exit 1
fi

echo "Configuração do NGINX para $DOMAIN na porta $PORT foi realizada com sucesso."
