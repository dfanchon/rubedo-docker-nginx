# Rubedo dockerfile
FROM centos:centos7
RUN yum -y update
RUN yum install -y make
# Install openssh
RUN yum -y install openssh-server epel-release && \
    yum -y install pwgen && \
    rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
# Install PHP env
RUN yum install -y httpd git vim php php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel gcc php-devel php-intl tar wget supervisor
RUN mkdir -p /var/lock/httpd /var/run/httpd /var/run/sshd /var/log/supervisor
COPY supervisord.conf /etc/supervisord.conf
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
EXPOSE 22 80
ENV AUTHORIZED_KEYS **None**
# Start script
ADD set_root_pw.sh /set_root_pw.sh
ADD start.sh /start.sh
RUN chmod +x /*.sh
CMD ["/start.sh"]
