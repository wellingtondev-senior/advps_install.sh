#!/bin/bash

# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Função de log para imprimir mensagens coloridas
log() {
  local color="$1"
  shift
  echo -e "${color}$@${NC}"
}

# Verifica se as variáveis de ambiente PORT e DOMAIN estão definidas
if [ -z "$PORT" ] || [ -z "$DOMAIN" ]; then
  echo "As variáveis de ambiente PORT e DOMAIN devem ser definidas."
  echo "Exemplo: PORT=80 DOMAIN=example.com ./script.sh"
  exit 1
fi

# Verificar se o NGINX está instalado, se não, instalar
if ! [ -x "$(command -v nginx)" ]; then
  echo 'Erro: NGINX não está instalado.' >&2
  echo 'Instalando NGINX...'
  sudo apt update
  sudo apt install -y nginx
fi

# Criar configuração do NGINX para o domínio
cat <<EOF | sudo tee /etc/nginx/sites-available/$DOMAIN
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Criar um link simbólico para habilitar o site
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Testar a configuração do NGINX
sudo nginx -t

# Reiniciar o NGINX para aplicar as mudanças
sudo systemctl restart nginx

echo "Configuração do NGINX para $DOMAIN na porta 80 foi concluída."

# Log da porta e domínio definidos
log $GREEN "A PORTA QUE VOCÊ DEFINIU É $PORT PARA O DOMÍNIO $DOMAIN"
