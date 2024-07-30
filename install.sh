#!/bin/bash

################################################################################
# Script de Configuração de Servidor - Ubuntu 20.04
# Autor: Wellington Ramos
# Data: [Data de Criação]
# Descrição: Este script instala e configura NGINX, Docker e Docker Compose,
#            além do NVM, Node.js LTS, PM2 e PostgreSQL em uma máquina Ubuntu 20.04.
#            Inclui a atualização dos pacotes, a adição de repositórios necessários,
#            a instalação de dependências e a configuração de serviços para serem
#            executados automaticamente.
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

log $BLUE "Iniciando a configuração do servidor..."

# Atualizar lista de pacotes e instalar dependências
log $YELLOW "Atualizando lista de pacotes e instalando dependências..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    ufw \
    certbot \
    python3-certbot-nginx

# Atualizar pacotes e instalar NGINX
log $YELLOW "Atualizando pacotes e instalando NGINX..."
sudo apt-get install -y nginx

# Habilitar e iniciar o serviço NGINX
log $YELLOW "Habilitando e iniciando o serviço NGINX..."
sudo systemctl enable nginx --quiet
sudo systemctl start nginx --quiet

# Verificar se o NGINX está escutando nas portas 80 e 443
log $YELLOW "Verificando se o NGINX está escutando nas portas 80 e 443..."
sudo netstat -tuln | grep ':80\|:443'

log $GREEN "NGINX instalado e em execução com sucesso."

# Configuração do diretório do projeto e execução do Docker
PROJECT_DIR="/opt/devcloud/api.devcloud.top"
REPO_URL="git@github.com:wellingtondev-senior/api.wellingtondev.com.git"

# Criar o diretório do projeto e clonar o repositório
log $YELLOW "Criando o diretório do projeto e clonando o repositório..."
sudo mkdir -p $PROJECT_DIR
sudo git clone $REPO_URL $PROJECT_DIR

# Garantir que o diretório do projeto pertença ao usuário atual
sudo chown -R $USER:$USER $PROJECT_DIR

# Entrar no diretório do projeto
log $YELLOW "Entrando no diretório do projeto..."
cd $PROJECT_DIR

# Instalar NVM, Node.js LTS e PM2
log $YELLOW "Instalando NVM, Node.js LTS e PM2..."

# Baixar e instalar o NVM
log $YELLOW "Baixando e instalando NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# Carregar o NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Adicionar NVM ao .bashrc para garantir que esteja disponível em novos terminais
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# Carregar o NVM no shell atual
source ~/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Adicionar Node.js e npm ao PATH
export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"

# Verificar se nvm, node e npm estão instalados corretamente
log $YELLOW "Verificando instalações do NVM, Node.js e npm..."
command -v nvm
command -v node
command -v npm

# Instalar a versão LTS do Node.js
log $YELLOW "Instalando a versão LTS do Node.js..."
nvm install --lts
nvm use --lts

# Instalar PM2 globalmente
log $YELLOW "Instalando PM2 globalmente..."
npm install -g pm2

# Verificar se pm2 está instalado corretamente
log $YELLOW "Verificando instalação do PM2..."
command -v pm2

# Configurar PM2 para iniciar automaticamente na inicialização do sistema
log $YELLOW "Configurando PM2 para iniciar automaticamente na inicialização do sistema..."
pm2 startup systemd -u $USER --hp $HOME
pm2 save

log $GREEN "NVM, Node.js LTS e PM2 instalados e configurados com sucesso."

# Verificar se o arquivo package.json existe
if [ ! -f "$PROJECT_DIR/package.json" ]; then
    log $RED "Erro: O arquivo package.json não foi encontrado no diretório $PROJECT_DIR."
    exit 1
fi

# Instalar dependências e construir o projeto
log $YELLOW "Instalando dependências do projeto..."
npm install

log $YELLOW "Construindo o projeto..."
npm run build

# Função para encontrar uma porta disponível
find_available_port() {
    local port=3000
    while sudo lsof -i -P -n | grep LISTEN | grep ":$port " >/dev/null; do
        ((port++))
    done
    echo $port
}

# Encontrar uma porta disponível e iniciar o projeto
PORT=$(find_available_port)

log $YELLOW "Atribuindo a porta $PORT para a aplicação..."

log $YELLOW "Iniciando o projeto com PM2 na porta $PORT..."
# Iniciar o projeto com PM2 e definir o nome da aplicação como "app"
PORT=$PORT pm2 start npm --name "app" -- start

# Salvar o estado do PM2
pm2 save

# Instalar PostgreSQL
log $YELLOW "Instalando PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

# Iniciar o serviço PostgreSQL
log $YELLOW "Iniciando o serviço PostgreSQL..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configurar PostgreSQL
log $YELLOW "Configurando PostgreSQL..."

# Alterar a senha do usuário postgres padrão
log $YELLOW "Alterando a senha do usuário padrão postgres..."
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'admin#master23451';"

# Criar banco de dados e usuário (tratando erros se já existirem)
log $YELLOW "Criando banco de dados e usuário..."
sudo -u postgres psql -c "CREATE DATABASE wellingtondev;" 2>/dev/null
sudo -u postgres psql -c "CREATE USER wellingtondev WITH ENCRYPTED PASSWORD 'wellingtondev_app_db_456_';" 2>/dev/null
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE wellingtondev TO wellingtondev;"

# Verificar versão do PostgreSQL para ajustar caminhos de configuração
PG_VERSION=$(pg_lsclusters -h | grep online | awk '{print $1}')
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

# Permitir conexões externas ao PostgreSQL
log $YELLOW "Configurando PostgreSQL para aceitar conexões externas..."
if [ -f "$PG_CONF" ]; then
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $PG_CONF
else
    log $RED "Arquivo de configuração do PostgreSQL não encontrado: $PG_CONF"
fi

if [ -f "$PG_HBA" ]; then
    echo "host all all 0.0.0.0/0 md5" | sudo tee -a $PG_HBA
else
    log $RED "Arquivo de configuração do PostgreSQL não encontrado: $PG_HBA"
fi

# Reiniciar o serviço PostgreSQL para aplicar as mudanças
log $YELLOW "Reiniciando o serviço PostgreSQL..."
sudo systemctl restart postgresql

log $GREEN "PostgreSQL instalado e configurado com sucesso."

# Configuração do diretório do projeto e execução do Docker
PROJECT_DIR_FRONT="/opt/devcloud/devcloud.top"
REPO_URL_FRONT="git@github.com:wellingtondev-senior/devcloud.top.git"

# Criar o diretório do projeto e clonar o repositório
log $YELLOW "Criando o diretório do projeto e clonando o repositório..."
sudo mkdir -p $PROJECT_DIR_FRONT
sudo git clone $REPO_URL_FRONT $PROJECT_DIR_FRONT

# Garantir que o diretório do projeto pertença ao usuário atual
sudo chown -R $USER:$USER $PROJECT_DIR_FRONT

# Entrar no diretório do projeto
log $YELLOW "Entrando no diretório do projeto..."
cd $PROJECT_DIR_FRONT

# Verificar se o arquivo package.json existe
if [ ! -f "$PROJECT_DIR_FRONT/package.json" ]; then
    log $RED "Erro: O arquivo package.json não foi encontrado no diretório $PROJECT_DIR_FRONT."
    exit 1
fi

# Instalar dependências e construir o projeto
log $YELLOW "Instalando dependências do projeto..."
npm install

log $YELLOW "Construindo o projeto..."
npm run build

# Iniciar o front-end com PM2
log $YELLOW "Iniciando o front-end com PM2 na porta 5810..."
pm2 start npm --name "frontend" -- start

# Salvar o estado do PM2
pm2 save

# Configurar NGINX para o front-end e a API

log $YELLOW "Configurando NGINX para devcloud.top e api.devcloud.top..."

# Configuração NGINX para devcloud.top
NGINX_CONF_DEV="/etc/nginx/sites-available/devcloud.top"
sudo bash -c "cat > $NGINX_CONF_DEV" <<EOL
server {
    listen 80;
    listen [::]:80;
    server_name devcloud.top www.devcloud.top;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name devcloud.top www.devcloud.top;

    ssl_certificate /etc/letsencrypt/live/devcloud.top/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/devcloud.top/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /opt/devcloud/devcloud.top;

    index index.html index.htm index.nginx-debian.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Configuração NGINX para api.devcloud.top
NGINX_CONF_API="/etc/nginx/sites-available/api.devcloud.top"
sudo bash -c "cat > $NGINX_CONF_API" <<EOL
server {
    listen 80;
    listen [::]:80;
    server_name api.devcloud.top;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name api.devcloud.top;

    ssl_certificate /etc/letsencrypt/live/api.devcloud.top/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.devcloud.top/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:5810;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Habilitar as configurações NGINX
sudo ln -s /etc/nginx/sites-available/devcloud.top /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/api.devcloud.top /etc/nginx/sites-enabled/

# Reiniciar o NGINX
log $YELLOW "Reiniciando o NGINX..."
sudo systemctl restart nginx

# Exibir as credenciais de acesso padrão
log $GREEN "Configuração concluída. Credenciais de acesso padrão:"
log $GREEN "PostgreSQL:"
log $GREEN "  Username: postgres"
log $GREEN "  Password: admin#master23451"
log $GREEN "Aplicação:"
log $GREEN "  Username: master"
log $GREEN "  Password: master"

# URLs de acesso
log $GREEN "Acesse a aplicação em: https://devcloud.top"
log $GREEN "Acesse a API em: https://api.devcloud.top"

log $GREEN "Script de configuração concluído com sucesso."
