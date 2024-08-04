# Instalação

### IMPORTANTE! 
```  chave publica ssh de todos os servidores que vc criar e vincule ao Github ```

## Instalação Inicial no servidor principal
Este comando efetuará a instalação e configuração inicial para o servidor principal das principais ferramentas (Nginx, NVM, PM2, PostgreSQL, Redis, e a aplicação e microserviços), além de abrir as portas necessárias e configurar o domínio **sem** o certificado SSL.

```bash
curl -fsSL https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/main.sh | bash
