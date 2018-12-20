FROM debian:jessie
# Add starter 
ADD start.sh /root/start.sh

RUN apt-get update && \
    apt-get install apache2 wget -y && \
    systemctl enable apache2 && \
    echo "SetEnv PROJECT_RUN_MODE production" >> /etc/apache2/apache2.conf && \
    echo "PROJECT_RUN_MODE=production" >> /etc/environment && \
    sed -i 's|^ServerTokens.*|ServerTokens Prod|' /etc/apache2/conf-available/security.conf && \
    sed -i 's|^ServerSignature.*|ServerSignature Off|' /etc/apache2/conf-available/security.conf && \
    ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load && \
    ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
    ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load && \
    ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf && \
    ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load && \
    apt-get -y install apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    apt-get update && apt-get install php7.2 php7.2-common php7.2-apcu php7.2-curl php7.2-gd php7.2-imagick php7.2-json php7.2-mbstring php7.2-mysql php7.2-readline php7.2-soap php7.2-xml php7.2-zip php7.2-redis php7.2-intl -y && \
    sed -i 's|^short_open_tag.*|short_open_tag = On|' /etc/php/7.2/apache2/php.ini && \
    sed -i 's|^max_execution_time.*|max_execution_time = 300|' /etc/php/7.2/apache2/php.ini && \
    sed -i 's|^max_input_time.*|max_input_time = 600|' /etc/php/7.2/apache2/php.ini && \
    sed -i 's|^error_reporting.*|error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT|' /etc/php/7.2/apache2/php.ini && \
    sed -i 's|^;date.timezone.*|date.timezone = Europe/Moscow|' /etc/php/7.2/apache2/php.ini && \
    sed -i 's|^short_open_tag.*|short_open_tag = On|' /etc/php/7.2/cli/php.ini && \
    sed -i 's|^;error_log.*|error_log = /var/log/php_cli_errors.log|' /etc/php/7.2/cli/php.ini && \
    sed -i 's|^error_reporting.*|error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT|' /etc/php/7.2/cli/php.ini && \
    sed -i 's|^;date.timezone.*|date.timezone = Europe/Moscow|' /etc/php/7.2/cli/php.ini && \
    echo "apc.shm_size=64M" >> /etc/php/7.2/mods-available/apcu.ini && \
    ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime && echo "Europe/Moscow" > /etc/timezone && \
    mv /etc/apache2 /etc/apache2-orig

ADD apache2-prefork.conf /etc/apache2-orig/mods-available/mpm_prefork.conf

RUN chmod +x /root/start.sh
CMD ["/bin/bash", "/root/start.sh"]

VOLUME ["/var/www", "/etc/apache2", "/mnt/maxminddb"]
