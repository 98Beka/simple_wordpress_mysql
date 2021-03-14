FROM alpine:3.12

RUN apk update && apk upgrade
RUN apk add openrc
RUN openrc && touch /run/openrc/softlevel

                #mysql
######################################################
RUN apk add mysql mysql-client
RUN mkdir -p /run/mysqld
RUN echo -e "\
[mysqld]                             	        \n\
user = root                          	        \n\
datadir = /var/lib/mysql             	        \n\
port = 3306                          	        \n\
log-bin = /var/lib/mysql/mysql-bin   	        \n\
bind-address = 0.0.0.0               	        \n\
skip-networking = false              	        \n\
" > /etc/mysql/my.cnf

RUN echo -e "\
echo \"CREATE DATABASE wordpress;\" | mysql                                             \n\
echo \"CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';\" | mysql  	            \n\
echo \"GRANT ALL PRIVILEGES ON wordpress.* TO admin IDENTIFIED BY 'admin';\" | mysql    \n\
" > /db_creat.sh
RUN chmod +x db_creat.sh

RUN echo -e "\
#!/bin/sh              					        \n\
/etc/init.d/mariadb setup				        \n\
rc-service mariadb start                        \n\
./db_creat.sh           			            \n\
php -S 0.0.0.0:5050 -t www/wordpress/           \n\
" > /run.sh
RUN chmod +x /run.sh
VOLUME ["/var/lib/mysql"]  

#SELECT User, Host, Password FROM mysql.user; //check users for first make comand -'mysql -u root -p' or just -'mysql'

#                 #wordpress
######################################################
RUN apk add php7 php7-fpm php7-opcache php7-gd \
php7-mysqli php7-zlib php7-curl php7-mbstring \
php7-json php7-session wget
# Download Wordpress
RUN mkdir www
RUN wget https://wordpress.org/latest.tar.gz \
&& tar -zxvf latest.tar.gz \
&& mv wordpress www/wordpress \
&& rm -rf latest.tar.gz
RUN rm -rf /www/wordpress/wp-config.php
COPY wp-config.php /www/wordpress/wp-config.php

EXPOSE 5050
CMD /run.sh