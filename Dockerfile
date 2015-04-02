# Rubedo dockerfile
FROM centos:centos7
RUN yum -y update; yum -y clean all
RUN yum install -y make; yum -y clean all
# Install openssh
RUN yum -y install openssh-server openssl-devel epel-release; yum -y clean all && \
    yum -y install pwgen; yum -y clean all && \
    rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
# Install PHP env
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum install -y nginx git vim php php-fpm php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel gcc php-devel php-intl tar wget supervisor; yum -y clean all
RUN mkdir -p /var/run/sshd /var/log/supervisor /var/log/sshd
COPY supervisord.conf /etc/supervisord.conf
# ADD Nginx config
ADD nginx.conf /etc/nginx/conf.d/default.conf
# Install PHP Mongo extension
RUN pecl install mongo
ADD mongo.ini /etc/php.d/mongo.ini
# Upgrade default limits for PHP
RUN sed -i 's#memory_limit = 128M#memory_limit = 512M#g' /etc/php.ini && \
    sed -i 's#max_execution_time = 30#max_execution_time = 240#g' /etc/php.ini && \
    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 20M#g' /etc/php.ini && \
    sed -i 's#;date.timezone =#date.timezone = "Europe/Paris"\n#g' /etc/php.ini \
    sed -i 's#;cgi.fix_pathinfo=1#cgi.fix_pathinfo=0#g' /etc/php.ini
    sed -r -i -e 's|^listen = 127.0.0.1.*$|listen = /var/run/php-fpm/php-fpm.sock|g' /etc/php-fpm.d/www.conf
# Expose port
EXPOSE 22 80
ENV AUTHORIZED_KEYS **None**
# Start script
COPY set_root_pw.sh /set_root_pw.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /*.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
