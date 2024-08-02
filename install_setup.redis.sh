#!/bin/bash

# Definir cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem cor

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
PORT=6379
sudo ufw allow $PORT/tcp && log $GREEN "Porta $PORT liberada no firewall." || {
    log $RED "Falha ao liberar a porta $PORT no firewall."
    exit 1
}

log $YELLOW "Configurando um novo usuário de acesso ao Redis..."
# Configurar um novo usuário de acesso ao Redis
REDIS_CONF="/etc/redis/redis.conf"
REDIS_USERS_CONF="/etc/redis/users.acl"

# Backup do arquivo de configuração original
sudo cp $REDIS_CONF ${REDIS_CONF}.backup && log $GREEN "Backup do arquivo de configuração original criado."

# Adicionar o novo usuário no arquivo de configuração do Redis
echo "user sintegre on +@all ~* &* >Sintegre#2024#" | sudo tee -a $REDIS_USERS_CONF && log $GREEN "Novo usuário adicionado ao Redis."

log $YELLOW "Configurando o Redis para acesso externo global..."
# Configurar o Redis para acesso externo global
sudo sed -i "s/^bind 127.0.0.1 ::1/bind 0.0.0.0 ::0/" $REDIS_CONF && log $GREEN "Redis configurado para acesso externo."
sudo sed -i "s/^# requirepass .*/requirepass Sintegre#2024#/" $REDIS_CONF && log $GREEN "Senha do Redis configurada."

log $YELLOW "Reiniciando o serviço Redis para aplicar as mudanças..."
# Reiniciar o serviço Redis para aplicar as mudanças
sudo systemctl restart redis && log $GREEN "Serviço Redis reiniciado." || {
    log $RED "Falha ao reiniciar o serviço Redis."
    exit 1
}

log $YELLOW "Testando as credenciais do Redis..."
# Testar as credenciais do Redis
REDIS_CLI_RESULT=$(redis-cli -h 127.0.0.1 -p $PORT -a Sintegre#2024# ping)

if [ "$REDIS_CLI_RESULT" == "PONG" ]; then
    log $GREEN "As credenciais do Redis estão corretas."
else
    log $RED "Falha ao autenticar no Redis com as credenciais fornecidas."
    exit 1
fi

log $GREEN "Configurações do Redis concluídas."
