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

# Log da porta e domínio definidos
log $GREEN "A PORTA QUE VOCÊ DEFINIU É $PORT PARA O DOMÍNIO $DOMAIN"
