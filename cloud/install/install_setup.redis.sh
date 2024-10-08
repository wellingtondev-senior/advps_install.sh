#!/bin/bash

# Limpar o cache do terminal
hash -r

# Definir cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem cor

# Variáveis para valores configuráveis
PASSWORD="Sintegre@20240"
PORT=6379

# Função para exibir log colorido
log() {
    echo -e "${1}${2}${NC}"
}

log $YELLOW "Atualizando os pacotes e instalando o Redis..."
# Atualizar os pacotes e instalar o Redis
sudo apt update && sudo apt install -y redis-server && log $GREEN "Redis instalado com sucesso." || {
    log $RED "Falha ao instalar o Redis."
    exit 1
}

log $YELLOW "Verificando se o firewall está ativo..."
# Verificar se o firewall está ativo e ativá-lo se necessário
sudo ufw status | grep -q "Status: active" || { 
    echo "y" | sudo ufw enable && 
    log $GREEN "Firewall ativado."
} || {
    log $RED "Falha ao ativar o firewall."
    exit 1
}

log $YELLOW "Permitindo a porta padrão do Redis no firewall..."
# Permitir a porta padrão do Redis no firewall
sudo ufw allow $PORT/tcp && log $GREEN "Porta $PORT liberada no firewall." || {
    log $RED "Falha ao liberar a porta $PORT no firewall."
    exit 1
}

log $YELLOW "Configurando o Redis para autenticação com senha e acesso externo..."
REDIS_CONF="/etc/redis/redis.conf"

# Configurar o Redis para autenticação com senha e acesso externo
sudo sed -i "s/^bind 127.0.0.1 ::1/bind 0.0.0.0/" $REDIS_CONF
sudo sed -i "s/^# requirepass .*/requirepass $PASSWORD/" $REDIS_CONF

# Reiniciar o serviço Redis para aplicar as mudanças
sudo systemctl restart redis-server && log $GREEN "Serviço Redis reiniciado." || {
    log $RED "Falha ao reiniciar o serviço Redis."
    exit 1
}

log $YELLOW "Testando as credenciais do Redis..."
# Testar as credenciais do Redis
REDIS_CLI_RESULT=$(redis-cli -h 127.0.0.1 -p $PORT -a $PASSWORD --no-auth-warning ping)

if [ "$REDIS_CLI_RESULT" == "PONG" ]; then
    log $GREEN "As credenciais do Redis estão corretas."
else
    log $RED "Falha ao autenticar no Redis com as credenciais fornecidas."
    exit 1
fi

# Criar a URL de conexão externa
EXTERNAL_IP=$(curl -s ifconfig.me)
CONNECTION_URL="redis://:$PASSWORD@$EXTERNAL_IP:$PORT"

log $YELLOW "URL de conexão externa para o Redis:"
echo -e "${GREEN}$CONNECTION_URL${NC}"

log $GREEN "Configurações do Redis concluídas."
