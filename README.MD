# Instalação

### IMPORTANTE! 
Gere chave publica ssh de todos os servidores que vc criar e vincule ao Github

## Instalação inicial na VPS Principal 
Esse comando efetuara a instalação e configuração  inicial para servidor principal das principais ferramentas (Nginx, NVM, PM2, PostgresSQL, Redis, e a aplicação e microserviços) e fara aberturas de portas necessarias e o dominio sem  A CONFIGURAÇÃO DO CERTIFICADO SSL 

``` curl -fsSL https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/main.sh | bash ```

