# Instalação

### IMPORTANTE!
Gere a chave pública SSH de todos os servidores que você criar e vincule-a ao GitHub.

Para gerar a chave SSH, use o comando:
```bash
ssh-keygen -t rsa -b 4096 -C "seu_email@exemplo.com"
```
Depois, visualize a chave pública no terminal com o comando:
```bash
cat ~/.ssh/id_rsa.pub
```

## Instalação Inicial no Servidor Principal
Este comando efetuará a instalação e configuração inicial para o servidor principal das principais ferramentas (Nginx, NVM, PM2, PostgreSQL, Redis, e a aplicação e microserviços), além de abrir as portas necessárias e deixar as aplicações rodando com PM2.

```bash
curl -fsSL https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/main.sh | bash
```



## Instalação da Controladora de Aplicações
Este comando efetuará a instalação e configuração inicial para o servidor principal das principais ferramentas (Nginx, NVM, PM2, PostgreSQL, Redis, e a aplicação e microserviços), além de abrir as portas necessárias e deixar as aplicações rodando com PM2.

```bash
curl -fsSL https://raw.githubusercontent.com/wellingtondev-senior/advps_install.sh/master/main.sh | bash
```


