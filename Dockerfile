# Rubedo dockerfile
FROM tutum/centos:centos7
RUN yum -y update
RUN yum install -y make
# Install PHP env
RUN yum install -y httpd git vim php php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel gcc php-devel php-intl tar wget
# Update httpd conf
RUN cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.old
RUN rm /etc/httpd/conf.d/welcome.conf -f
RUN sed -i 's#/var/www/html#/var/www/html/rubedo/public#g' /etc/httpd/conf/httpd.conf
RUN sed -i 's#Options Indexes FollowSymLinks#Options -Indexes +FollowSymLinks#g' /etc/httpd/conf/httpd.conf
RUN sed -i 's#AllowOverride None#AllowOverride All#g' /etc/httpd/conf/httpd.conf
RUN sed -i 's#ServerName www.example.com:80#ServerName www.example.com:80\nServerName localhost:80#g' /etc/httpd/conf/httpd.conf
# Install PHP Mongo extension
RUN pecl install mongo
ADD mongo.ini /etc/php.d/mongo.ini
# Upgrade default limits for PHP
RUN sed -i 's#memory_limit = 128M#memory_limit = 512M#g' /etc/php.ini
RUN sed -i 's#max_execution_time = 30#max_execution_time = 240#g' /etc/php.ini
RUN sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 20M#g' /etc/php.ini
RUN sed -i 's#;date.timezone =#date.timezone = "Europe/Paris"\n#g' /etc/php.ini
# Expose port
EXPOSE 80
#Install Rubedo
RUN wget -O /var/www/html/rubedo.tar.gz https://github.com/WebTales/rubedo/releases/download/3.0.0/rubedo.tar.gz
RUN tar -zxvf /var/www/html/rubedo.tar.gz -C /var/www/html
RUN rm -f /var/www/html/rubedo.tar.gz
Run chown apache:apache /var/www/html/rubedo/config/autoload/local.php
# Start httpd
# ENTRYPOINT /usr/sbin/httpd -DFOREGROUND
# Start script
ADD start /start.sh
RUN chmod 777 /start.sh
CMD ["/start"]
