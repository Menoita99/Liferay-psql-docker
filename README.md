

# Instalação Liferay CE/DXP em Linux

## Conteúdo
[Acerca deste documento	2](#_Toc79571637)

[Pré-instalação da máquina	3](#_Toc79571638)

[Ajustes ao sistema operativo	3](#_Toc79571639)

[Instalação do Liferay	6](#_Toc79571640)

[Configuração do serviço “liferay” no sistema	9](#_Toc79571641)

[Configuração de backups e política de retenção	9](#_Toc79571642)

[Instalação do Reverse Proxy	10](#_Toc79571643)

[Melhorias na segurança	13](#_Toc79571644)

[Controlo de tempos de resposta do Liferay	18](#_Toc79571645)

[Instalação do Hotfixes e Service Packs (DXP apenas)	19](#_Toc79571646)

[Configuração do hostname das páginas públicas e privadas	20](#_Toc79571647)

[Erros 404 (Not Found) e redireccionamento de URLs antigos	20](#_Toc79571648)

[ANEXO: Script “/opt/Liferay/liferay-action.sh”	23](#_Toc79571649)

[ANEXO: Backups do CMS para o Git do projecto	28](#_Toc79571650)

[ANEXO: Script “/root/renew-le-certificate.sh”	29](#_Toc79571651)

[ANEXO: Gestão de pacotes em distribuições RedHat	30](#_Toc79571652)

[ANEXO: Configuração do serviço em systemd	31](#_Toc79571653)



# Acerca deste documento
**Histórico de versões:**

|**Data versão**        |**Autores**|**Motivo da revisão**|
| :- | :- | :- |
|23/12/2020      |Fernando Fernandez|Versão inicial|
|21/42/2022      |Rui Menoita|Versão inicial docker|

<br>


**Audiência do documento:**

Responsáveis internos pela instalação de Liferay em ambientes de desenvolvimento de projectos


# Pré-instalação da máquina
Normalmente o processo é iniciado com a solicitação de uma VM Azure ao IT, que nos entrega um servidor instalado com um **Ubuntu Server LTS 20.04** e um user+password com permissões de “sudo”. **Para efeitos de simplicidade este utilizador será referido como “liferayadmin” no resto do manual, embora seja frequente que o user criado pelo IT tenha um nome diferente.**
<br>
<br>
## Ajustes ao sistema operativo
---
<br>

Se não estiverem instalados por default, os seguintes pacotes devem ser adicionados ao sistema: 
```
 sudo apt install net-utils mailutils ntpdate ntp
```
<br>
<br>

## Servidor de email
---
<br>

Detalhar solução que não passe pela firewall


Configuração do Postfix: configurar o servidor de correio como “satellite system” de um servidor de email disponível no cliente. Se não houver servidor de email, deixar instalação default (internet site). De modo a que o sistema não possa ser usado como mail relay para spammers, é preciso fechar a recepção do exterior com:

1) alteração do parâmetro inet\_interfaces no /etc/postfix/main.cf para “inet\_interfaces = 127.0.0.1”
1) uma firewall que impeça conexões à porta 25/SMTP para não aceitar email vindo do exterior (reforço opcional)

Testar o envio de email com o comando “echo teste | mail -s teste user@dominio.tld” com um endereço válido para o destinatário.
<br>
<br>

## Memória virtual
---
<br>

Para que um eventual excesso de utilização de memória não bloqueie a máquina será conveniente configurar alguma memória virtual (swapfile). Para isso é preciso correr os seguintes comandos:
```
 sudo fallocate -l 4G /swapfile
 sudo chmod 600 /swapfile
 sudo mkswap /swapfile
```
Se o fallocate não funcionar, usar a alternativa:
```
 dd if=/dev/zero of=/usr2/swapfile bs=1M count=4096
```

Em seguida, deve ser adicionada esta linha ao ficheiro “/etc/fstab”:
```
 /swapfile swap swap defaults 0 0
```

A activação do swap será feita quando a máquina fizer reboot mas pode ser feita imediatamente, sem reboot, com o comando:
```
 swapon -a
```
A activação do swapfile poderá ser confirmada com o comando:
```
 swapon -s
```

<br>
<br>

## Relógio do sistema
---
<br>

O relógio do sistema é acertado automaticamente pelo serviço ntp. No entanto, quando a diferença é demasiado grande, o ntp não acerta o relógio automaticamente. Nesse caso é preciso usar o ntpdate.

Para acertar inicialmente o relógio do sistema executar os seguintes comandos:
```
 service ntp stop
 ntpdate 0.pt.pool.ntp.org
 service ntp start
```
Se houver problemas na sincronização, confirmar que os servidores ntp referidos no ficheiro /etc/ntp.conf estão acessíveis e não bloqueados por qualquer firewall.

Em caso de necessidade, acrescentar os seguintes servidores ao ntp.conf:
```
server 0.pt.pool.ntp.org
server 3.europe.pool.ntp.org
server 1.europe.pool.ntp.org
```
<br>
<br>

## Instalação do docker
---
<br>

Documentação do docker: https://docs.docker.com/engine/install/ubuntu/

1- Actualizar o apt e instalar os packages para permitir que o apt utilize um repositório sobre HTTPS:
```
 sudo apt-get update
 sudo apt-get install ca-certificates curl gnupg lsb-release
```

2- Adicionar a chave oficial do GPG do Docker:
```
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

3- Utilizar o seguinte comando para configurar o repositório stable:
```
 echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu 
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

4- Instalar o docker e o docker-compose:
```
 sudo apt-get update
 sudo apt-get install docker-ce docker-ce-cli containerd.io
```

5- Criar o grupo docker:
```
 sudo groupadd docker
```

6- Adicionar o utilizador currente ao grupo docker:
```
 sudo usermod -aG docker $USER
 newgrp docker 
```

7- Se tudo estiver bem ao correr o comando abaixo deverá ver a mensagem
**Hello from Docker! This message shows that your installation appears to be working correctly.**
```
 docker run hello-world
```
<br>
<br>

## Setup
---
<br>

Faça o download da pasta com os ficheiros de configuração do repositório XD Commons:
```
 TODO
```

Deve verificar qual a imagem mais recente do liferay em https://hub.docker.com/r/liferay/portal/tags e substituir o valor image no ficheiro docker-compose.yml:
```
  liferay:
    image: 'liferay/portal:{NOVA_VERSAO}'
```

No ficheiro liferay.service deve alterar o nome do utilizador para o utilizador atual e deve atualizar o caminho do ficheiro docker-compose.yml

```
[Unit]
Description=Liferay service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User={UTILIZADOR_ATUAL}
ExecStart=docker-compose -f {ABSOLUTE_PATH}/docker-compose.yml up
ExecStop=docker-compose -f {ABSOLUTE_PATH}/docker-compose.yml down

[Install]
WantedBy=multi-user.target
```
<br>
<br>

## Adicionar o serviço ao systemd
---
<br>

Para adicionar o serviço liferay é necessário adicionar o ficheiro liferay.service à pasta /etc/systemd/system.

1- Criar um softlink para a pasta system:
```
 sudo ln -s {ABSOLUTE_PATH}/liferay.service /etc/systemd/system/liferay.service
```
2- Ativar o serviço:
```
 sudo systemctl enable liferay
```
3- Começar o serviço:
```
 sudo systemctl start liferay
```
4- Para Ver o status do serviço pode correr o comando:
```
 sudo systemctl status liferay
```
5- Para ver os logs do liferay pode correr:
**Nota: tem de estar no mesmo folder que contêm o ficheiro docker-compose.yml**
```
 docker-compose logs -f liferay
```
Não havendo erros, o servidor deverá estar pronto a responder cerca de um minuto depois, no endereço:
```
 http://[public_IP]:8080
```

O primeiro login do liferay deve ser feito com as seguintes credenciais:
|**Utilizador**|**Palavra passe**|
| :- | :- |
|liferay@inetum.com      |liferay|

<br>
<br>

## Configuração de backups e política de retenção
---
<br>
Para realizar diariamente um backup do Liferay, será conveniente configurar uma tarefa noturna no cron usando o comando:
```
 sudo crontab -e
```

Este comando lança um editor (escolher o “nano” se não se estiver à vontade no Linux) onde deve ser inserida uma linha com:
```
# m h  dom mon dow   command
  30 19  *   *   *    sh {ABSOLUTE_PATH}/backup/backup.sh
```

Para as máquinas que “dormem” durante a noite, em vez da configuração anterior, será conveniente fazer um backup uns minutos depois de cada reboot:
```
 # m h  dom mon dow   command
 @reboot              sleep 600; sh {ABSOLUTE_PATH}/backup/backup.sh
```
O processo de backup deixa na pasta “{ABSOLUTE_PATH}/backup”:

- arquivo do dia, designado “backup-liferay.tgz”
- arquivo anterior, designado “backup-liferay.tgz.old” 

Os arquivos de backup deverão ser copiados diariamente para fora do servidor para maior segurança, implementando nesse servidor a política de retenção de backups que equilibre a necessidade de segurança com o espaço em disco ocupado. 

Como política de retenção de backups sugere-se a seguinte:

- Retenção por 7 dias dos backups diários
- Retenção por 30 dias dos backups de dia 1, 10 e 20 de cada mês
- Retenção por 1 ano do backup do dia 1 de cada mês

<br>
<br>

## Instalação do Reverse Proxy
---
<br>
Tal como no ambiente DEV, será necessário instalar um reverse proxy (apache httpd, por exemplo) que 

- receba pedidos no porto 80 (http) e os redireccione para o 443 (https)
- receba pedidos https, apresente um certificado válido ou aceitável no contexto do projecto (o snake-oil, default do apache, pode ser suficiente, mas neste exemplo usamos o letsencrypt)
- reencaminhe os pedidos, por http, para o liferay que estará a responder no porto 80

Para instalar o Apache2 HTTPd é preciso adicionar o respectivo pacote ao sistema e ligar algumas opções, com os comandos:
```
 sudo apt install apache2 letsencrypt

 sudo ln -s /etc/apache2/mods-available/{ssl.*,socache_*,proxy*,slotmem_shm*,xml2enc*} /etc/apache2/mods-enabled

 sudo ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled
```

Após a instalação do apache2 a máquina deve ficar a responder ao porto 80/http. A configuração do letsencrypt permitirá aceder por https/443. Para instalar e configurar o letsencrypt correr:

```
 sudo apache2 stop

 certbot certonly -n -d {PUBLIC_HOSTNAME} --standalone --agree-tos -email liferay-support-pt@gfi.fr
```

O ficheiro “/etc/apache2/sites-enabled/default-ssl” deverá ser editado para ficar com o seguinte conteúdo:
```
 <VirtualHost _default_:443>

      ServerAdmin liferay-support-pt@gfi.fr

      DocumentRoot "/var/www/html"

      ProxyPass /error/ ! 

      ErrorDocument 503 /error/503.html

      ProxyPreserveHost On

      ProxyPass / http://localhost:8080/

      ProxyPassReverse / http://localhost:8080/

      SSLEngine on

      SSLCertificateFile      /etc/letsencrypt/live/{PUBLIC_HOSTNAME}/fullchain.pem

      SSLCertificateKeyFile   /etc/letsencrypt/live/{PUBLIC_HOSTNAME}/privkey.pem

 </VirtualHost>
```

No ficheiro /etc/apache2/sites-available/000-default.conf, que deverá estar previamente linkado para /etc/apache2/sites-enabled, devemos substituir o seu conteúdo por:
```
<VirtualHost *:80>
      
      ServerAdmin liferay-support-pt@gfi.fr
      
      Redirect permanent / https://{PUBLIC_HOSTNAME}/
      
</VirtualHost>
```
Para que qualquer paragem no Liferay seja anunciada como “manutenção”, deverá ser criado o ficheiro “/var/www/html/error/503.html” com o seguinte conteúdo:
```
 <html>

   <head><title>Website currently under maintenance / Site em manuten&ccedil;&atilde;o</title></head>

   <body>

     <div style=”padding: 50px;”>

       <h1>We’re sorry</h1>

       <p>We apologise but this website is currently under maintenance. Please come back in a few minutes.</p>

       <br/>

       <h1>Pedimos desculpa</h1>

       <p>Lamentamos, mas este site est&aacute; neste momento em manuten&ccedil;&atilde;o. Por favor volte dentro de alguns minutos.</p>

     </div>

   </body>

 </html>
```
Em seguida, será necessário reiniciar o serviço:
```
 sudo service apache2 restart
```
A renovação automática do certificado do letsencrypt é realizada pelo script /root/renew-le-certificates.sh (ver anexo no final do documento) que deve ser lançado do crontab do root a hora que seja conveniente e em que a máquina está ligada (neste exemplo, às 8:30 de 2ª feira):
```
 30 08  *   *   2     sh /root/renew-le-certificate.sh
```

É de notar o endereço de email usado no ServerAdmin, que corresponde a um grupo de Outlook que distribui os emails chegados por um grupo de pessoas responsáveis pelo suporte Liferay na Itnetum PT.

No ficheiro portal-ext.properties do servidor Liferay será necessário activar a propriedade:
```
 web.server.protocol=https
```

Em seguida, será necessário reiniciar o serviço:
```
sudo systemctl start liferay
```

O acesso inicial à interface web do Liferay poderá ser realizado após o arranque do servidor apontando um browser a **https://public\_hostname**

Para além do utilizador de administração de default, definido na configuração inicial e referido acima, convirá criar utilizadores independentes para cada uma das pessoas que irão trabalhar no site. Sugere-se que se crie pelo menos um utilizador com role/papel/perfil de “Portal Administrator” e que se desactive o utilizador de default.


<br>
<br>

## Melhorias de segurança
---
<br>
Os pontos seguintes explicitam alguns ajustes à segurança e estabilidade do servidor. 

As alterações à configuração do Liferay deverão ser precedidas de um *shutdown* ao Liferay e seguidas de um *restart* a esse serviço.

O *shutdown* será feito com o comando:
```
 sudo systemctl stop liferay
```
O *restart* será feito com o comando:
```
 sudo systemctl liferay start
```
As alterações à configuração do Apache deverão ser seguidas de um *restart* a esse serviço, com o comando:
```
 sudo service apache2 restart
```

<br>
<br>

## 1. Fechamento de portos
---
<br>

Depois de garantir que se consegue aceder ao Liferay pelo https do Apache HTTPd, para que o Tomcat do Liferay passe a responder apenas através do Apache HTTPd, será conveniente fechar o acesso pelo porto 8080.

Antes desta alteração será necessário fazer desligar o serviço liferay:
```
sudo systemctl stop liferay
```
Em seguida deve-se alterar o /opt/liferay/liferay-\*/tomcat\*/conf/server.xml. O conector 8080 deve passar a incluir o atributo:
```
address=”127.0.0.1”
```

<br>
<br>

## 2. Pacotes de segurança no Linux
---
<br>


Os seguintes pacotes acrescentam segurança ao Linux sem grande esforço:

- fail2ban – auto-bloqueio de certos IPs quando há demasiados logins falhados em serviços comuns
- unattended-upgrades – actualização diária de pacotes (não faz reboot por defeito mas pode ser configurado para isso)

<br>
<br>

## 3. Bloqueio de acesso a sites alojados no mesmo host
---
<br>

Se a mesma máquina aloja vários sites com diferentes hostnames convirá que cada hostname só dê acesso às páginas do respectivo site.

Para isso será necessário bloquear no apache, em cada VirtualHost, o acesso aos restantes sites:

Isso pode ser feito com a tag “Location”:
```
 <IfModule mod_ssl.c>

    <VirtualHost *:443>

       ServerName hostname-site1.tld

       <Location /web/site2>

          Order Deny,Allow

          Deny from all

       </Location>

       RequestHeader set X-Forwarded-Proto "https"

       ProxyPreserveHost on

       ProxyPass / http://127.0.0.1:8080/ flushpackets=on

       ProxyPassReverse / http://127.0.0.1:8080/

       SSLEngine on

       SSLCertificateFile    /etc/ssl/hostname-site1.tld/site.cer

       SSLCertificateKeyFile /etc/ssl/hostname-site1.tld/site1.key

       SSLCertificateChainFile /etc/ssl/hostname-site1.tld/site1.cer

    </VirtualHost>

 </IfModule>
```
<br>
<br>

## 4. Configuração do Anti-vírus
---
<br>

Instalar clamav (antivírus) e clamd (serviço AV):
```
 sudo apt install clamav-daemon
```

Adicionar ao ficheiro /etc/clamav/clamd.conf:
```
 TCPSocket 3310

 TCPAddr 127.0.0.1
```

Reiniciar o serviço:
```
 sudo service clamav-daemon restart
```
Adicionar ao portal-ext.properties do Liferay:
```
 dl.store.antivirus.enabled=true
```

Reiniciar o Liferay.

<br>
<br>

## Controlo de tempos de resposta do Liferay
---
<br>


Em certos casos será necessário monitorizar o desempenho do Tomcat/Liferay. Uma forma prática será activar a AccessLogValve do Tomcat. Para isso, será necessário editar o ficheiro conf/server.xml, descomentar a Valve e acrescentar o tamanho e tempo de resposta do pedido:

```
 <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
        prefix="localhost_access_log" suffix=".txt"
        pattern="%h %l %u %t &quot;%r&quot; %s **%bbytes %Dms**" /> 
```

Com esta configuração, todos os pedidos ficam registados no ficheiro logs/localhost\_access\_log[data].txt do tomcat, com este aspecto:
```
 127.0.0.1 - - [01/Feb/2021:16:15:24 +0000] "GET /web/guest HTTP/1.1" 200 144193bytes 753ms
```
**Nota: convirá que esta configuração não fique activa permanentemente em ambiente de produção pois pode ocupar bastante espaço em disco e tornar a resposta do servidor um pouco mais lenta.**

<br>
<br>

## Configuração do hostname das páginas públicas e privadas
---
<br>

As páginas públicas de um site são normalmente acedidas por <https://hostname.tld/web/site> e as privadas por <https://hostname.tld/group/site>. Para que as páginas publicas possam ser acedidas apenas como <https://hostname.tld> e as privadas por <https://private.hostname.tld> é preciso ir à configuração do site no Liferay e registar esses nomes na configuração de páginas públicas e privadas.

<br>
<br>

## Erros 404 (Not Found) e redireccionamento de URLs antigos
---
<br>

Para usar uma página customizada de NotFound (404) será necessário, depois de criar a página, configurar no portal-ex.properties:
```
layout.friendly.url.page.not.found=/web/guest/notfound-page
```

No caso de o Liferay ser instalado para substituir um site pré-existente poderá ser útil configurar redirects permanentes de URLs populares do site antigo. Para isso será necessário configurar uma tabela de redirects em vez de apresentar o erro 404 ou a págna de NotFound customizada.

Para a gestão dos redirects e das URLs populares convirá analisar a listagem de 404:

- Em Liferay 7.3+ está disponível em Site Config
- Em versões anteriores será necessário analizar os logs e extrair essa listagem

Na versão 7.3 o Liferay a tabela de redirects pode ser directamente carregada no UI do Liferay, em Site Config. 

Numa versão anterior à 7.3, será necessário colocar a tabela de redirects na configuração do apache. Esta configuração poderá ser mais simples ou mais complexa, consoante os URLs a redireccionar contenham query-strings ou não.

**URLs simples sem Query String (Liferay < 7.3)**

O redireccionamento deverá ser realizado no ficheiro /etc/apache2/sites-enabled/default-ssl.conf, antes e depois da configuração do reverse proxy:
```
 <VirtualHost _default_:443>

     ServerAdmin liferay-support-pt@gfi.fr

     ProxyPreserveHost On

     # Avoid proxy pass for each one of the old urls

     **ProxyPass "/old-url-1 " !**

     **ProxyPass "/old-url-2 " !**

     # Default is to pass to Liferay

     ProxyPass / http://localhost:8080/

     ProxyPassReverse / http://localhost:8080/

     SSLEngine on

     SSLCertificateFile      /etc/letsencrypt/live/www.hostname.tld/cert.pem

     SSLCertificateKeyFile   /etc/letsencrypt/live/www.hostname.tld/privkey.pem

 	   # Redirect old urls to new urls

     Redirect Permanent /old-url-1 https://www.hostname.tld/new-url-1

     Redirect Permanent /old-url-2 [https://www.hostname.tld/new-url-2](https://www.hostname.tld/new-url-2)

 </VirtualHost>
```

Ver configuração do Apache da Cimpor
Nota: este modo de redireccionamento não funciona com query-strings (casos como /www.hostname.tld/old-url-1?param1=x&param2=y); para esses casos é necessário usar o mod\_rewrite, como se exemplifica a seguir.

**URLs com Query Strings (Liferay < 7.3)**

Nos casos em que os URLs a redireccionar incluem parâmetros passados por query-string, terá que ser usado o mod\_rewrite do Apache e uma sintaxe de configuração diferente. A título de exemplo, imaginem-se os seguintes URLs, em que o conteúdo é distinguido pelo parâmetro “id”:

- https:///www.hostname.tld/old-url?id=1234
- https:///www.hostname.tld/old-url?id=9876

Para esse caso, o redireccionamento far-se-á do seguinte modo:
```
 <VirtualHost _default_:443>

     ServerAdmin liferay-support-pt@gfi.fr

     ProxyPreserveHost On

     # Avoid proxy pass for each one of the old urls without query string

     **ProxyPass "/old-url " !**

     # Default is to pass to Liferay

     ProxyPass / http://localhost:8080/

     ProxyPassReverse / http://localhost:8080/

     SSLEngine on

     SSLCertificateFile      /etc/letsencrypt/live/www.hostname.tld/cert.pem

     SSLCertificateKeyFile   /etc/letsencrypt/live/www.hostname.tld/privkey.pem

 	# Redirect old urls to new urls

     **RewriteEngine  on**

     **RewriteCond "%{QUERY_STRING}" "id=1234"**

     **RewriteRule "^/old-url" "/new-url-1"  [R]**

     **RewriteCond "%{QUERY_STRING}" "id=9876"**

     **RewriteRule "^/old-url" "/new-url-2"  [R]**

> </VirtualHost>
```

# ANEXO: Backups do CMS para o Git do projecto
Configuração e teste do WebDAV:

- Convém que haja um user com role de Site Admin para o site que se quer guardar (senão dá erro 412)
- Conexão por https no Windows falha se certificado não for confiável (dedução)
- Criar pastas “ADTs” e “STRUCTS+TEMPLATES” previamente, na pasta principal da cópia de trabalho do git
- Copiar BAT para a pasta principal da cópia de trabalho do git
- Testar cada um dos comandos do BAT à mão, na linha de comandos
- Em caso de dificuldades ligar logs do Liferay para classes “webdav”

Windows Batch Script para backup de estruturas e templates:
```
 REM ==== Mount Webdav as drive (Adapt URL, user and password)

 net use N: http://10.200.3.55:8080/webdav/guest/ /user:backups@cm-oeiras.pt password

 REM ==== Copy structs and templates

 robocopy N:\application_display_template\Templates ADTs /MIR

 robocopy N:\journal STRUCTS+TEMPLATES /MIR

 REM ==== Unmount drive

 net use N: /delete
```

# ANEXO: Script “/root/renew-le-certificate.sh”

```
 #!/bin/sh

 export PATH=$PATH:/usr/sbin

 service apache2 stop > /tmp/jk 2>&1

 letsencrypt renew  -m fernando.m.fernandez@gfi.world --agree-tos >> /tmp/jk 2>&1

 service apache2 start >> /tmp/jk 2>&1

 mail -s "Letsencrypt renewall" fernando.m.fernandez@gfi.world < /tmp/jk

 rm /tmp/jk
```

# ANEXO: Gestão de pacotes em distribuições RedHat
Este documento parte do princípio de que o sistema operativo será um Ubuntu, uma distribuição de Linux bastante popular baseada em Debian GNU Linux. Alguns clientes poderão preferir uma distribuição Linux baseada em RedHat, como RHEL, CentOS ou Fedora. Isto significa que não só os nomes dos pacotes poderão ser diferentes como os comandos a utilizar também serão diferentes. A tabela seguinte apresenta as utilizações mais comuns.


|**Propósito**|**Comando em Debian**|**Comando em RedHat**|
| :- | :- | :- |
|Actualizar lista de pacotes|apt update|(não necessário)|
|Actualizar pacotes desactualizados|apt upgrade|dnf upgrade|
|Pesquisar na lista de pacotes|apt search *pattern*|dnf  search *pattern*|
|Instalar pacote|apt install *package\_name*|dnf install *package\_name*|
|Remover pacote|apt remove *package\_name*|dnf remove *package\_name*|
|Remover pacote, dados e config|apt purge *package\_name*||
|Info pacote|apt show *package\_name*|dnf show package\_name|