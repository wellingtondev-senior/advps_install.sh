#!/bin/bash

################################################################################
# Parte 6: Instalar e Configurar PostgreSQL
################################################################################

# Cores para log
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor

# Função de log para imprimir mensagens com timestamps e cores
log() {
    local color=$1
    shift
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NC}"
}

log $YELLOW "Instalando PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

log $YELLOW "Iniciando o serviço PostgreSQL..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

log $YELLOW "Configurando PostgreSQL..."

log $YELLOW "Alterando a senha do usuário padrão postgres..."
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'admin#master23451';"

log $YELLOW "Criando banco de dados e usuário..."
sudo -u postgres psql -c "CREATE DATABASE wellingtondev;" 2>/dev/null
sudo -u postgres psql -c "CREATE USER wellingtondev WITH ENCRYPTED PASSWORD 'wellingtondev_app_db_456_';" 2>/dev/null
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE wellingtondev TO wellingtondev;"

PG_VERSION=$(pg_lsclusters -h | grep online | awk '{print $1}')
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

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

log $YELLOW "Reiniciando o serviço
