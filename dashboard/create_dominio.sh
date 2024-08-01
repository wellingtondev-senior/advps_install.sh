#!/bin/bash



# Cores para log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Verifica se as variáveis de ambiente PORT e DOMAIN estão definidas
if [ -z "$PORT" ] || [ -z "$DOMAIN" ]; then
  echo "As variáveis de ambiente PORT e DOMAIN devem ser definidas."
  echo "Exemplo: PORT=80 DOMAIN=example.com ./script.sh"
  exit 1
fi

echo $GREEN "A PORTA QUE VC QUE SETAR $PORT PARA DOMINIO $DMINIO" 

