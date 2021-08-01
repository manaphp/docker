FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp

RUN apt-get update && apt-get install -y software-properties-common\
    &&add-apt-repository -y ppa:ondrej/php\
	&&apt-get install -y --no-install-recommends curl build-essential

ENV PHP_VERESION 7.4
ENV PHP_API_VERSION 20190902

RUN  apt-get install -y --no-install-recommends php${PHP_VERESION}-dev

RUN mkdir -p /tmp/extensions

RUN curl -o swoole.tar.gz https://github.com.cnpmjs.org/swoole/swoole-src/archive/v4.6.7.tar.gz -L\
    &&tar zxvf swoole.tar.gz\
    &&cd swoole-*\
    &&phpize\
    &&./configure\
        --enable-openssl\
        --enable-http2\
        --enable-sockets\
        --enable-mysqlnd\
    &&make && make install\
    &&cp /usr/lib/php/${PHP_API_VERSION}/swoole.so /tmp/extensions/swoole.so\
    &&rm swoole* -rf

RUN curl -o sdebug.tar.gz https://github.com.cnpmjs.org/swoole/sdebug/archive/refs/tags/sdebug_2_9-beta.tar.gz -L \
    &&tar zxvf sdebug.tar.gz\
    &&cd sdebug-*/\
    &&phpize &&./configure &&make &&make install\
    &&cp /usr/lib/php/${PHP_API_VERSION}/xdebug.so /tmp/extensions/sdebug.so\
    && rm sdebug* -rf
########################################################################################################################
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update  && apt-get install -y software-properties-common\
    &&add-apt-repository -y ppa:ondrej/php\
    &&apt-get install -y --no-install-recommends bash-completion telnet net-tools iputils-ping iproute2 lsof strace htop ca-certificates curl wget vim-tiny dos2unix cron logrotate busybox-syslogd mysql-client\
    &&echo '. /etc/bash_completion' >> /root/.bashrc\
    &&ln -s /usr/bin/vim.tiny /usr/bin/vim && cp /etc/vim/vimrc.tiny /root/.vimrc&&echo "set nocompatible\nset backspace=2\nset number" >> /root/.vimrc\
    &&ln -s -f /usr/share/zoneinfo/PRC /etc/localtime\
    &&sed -i\
        -e 's|@include common|#@include common|'\
        -e 's|session       required   pam_env.so envfile=/etc/default/locale|#session       required   pam_env.so envfile=/etc/default/locale|'\
        /etc/pam.d/cron

RUN curl -o composer.phar https://install.phpcomposer.com/composer.phar -L\
    &&chmod a+x composer.phar\
    &&mv composer.phar /usr/local/bin/composer

WORKDIR "/var/www/html"

ENV PHP_VERESION 7.4
ENV PHP_API_VERSION 20190902

RUN apt-get install -y --no-install-recommends\
        php${PHP_VERESION}-fpm\
        php${PHP_VERESION}-xdebug\
        php${PHP_VERESION}-amqp\
        php${PHP_VERESION}-stomp\
        php${PHP_VERESION}-mongodb\
        php${PHP_VERESION}-redis\
        php${PHP_VERESION}-mbstring\
        php${PHP_VERESION}-intl\
        php${PHP_VERESION}-gd\
        php${PHP_VERESION}-imagick\
        php${PHP_VERESION}-mysql\
        php${PHP_VERESION}-pgsql\
        php${PHP_VERESION}-odbc\
        php${PHP_VERESION}-sqlite3\
        php${PHP_VERESION}-curl\
        php${PHP_VERESION}-igbinary\
        php${PHP_VERESION}-msgpack\
        php${PHP_VERESION}-xml\
        php${PHP_VERESION}-xmlrpc\
        php${PHP_VERESION}-apcu\
        php${PHP_VERESION}-memcache\
        php${PHP_VERESION}-memcached\
        php${PHP_VERESION}-bcmath\
        php${PHP_VERESION}-gmp\
        php${PHP_VERESION}-ldap\
        php${PHP_VERESION}-soap\
        php${PHP_VERESION}-imap\
        php${PHP_VERESION}-bz2\
        php${PHP_VERESION}-solr\
        php${PHP_VERESION}-geoip\
        php${PHP_VERESION}-tidy\
        php${PHP_VERESION}-zip\
        php${PHP_VERESION}-mcrypt\
        php${PHP_VERESION}-protobuf\
        php${PHP_VERESION}-yaml\
    &&mkdir -p /run/php\
    &&mkdir -p /var/log/php
RUN ln -s /etc/php/${PHP_VERESION}/cli /etc/php/cli && ln -s /etc/php/${PHP_VERESION}/fpm /etc/php/fpm\
    &&sed -i \
        -e 's|listen =.*|listen = 9000|'\
        -e 's|;access.log.*|access.log = /var/log/php/access.log|'\
        -e 's|;access.format|access.format|'\
        /etc/php/fpm/pool.d/www.conf\
    &&sed -i\
        -e 's|error_log =.*|error_log = /var/log/php/fpm-error.log|'\
        /etc/php/fpm/php-fpm.conf\
    &&sed -i\
        -e 's|;error_log = php_errors.log|error_log = /var/log/php/error.log|'\
        /etc/php/fpm/php.ini\
    &&ln -s /usr/sbin/php-fpm${PHP_VERESION} /usr/sbin/php-fpm\
    &&touch /etc/php/fpm.conf && echo 'include=/etc/php/fpm.conf'>>/etc/php/fpm/php-fpm.conf\
    &&touch /etc/php/php.ini\
        && ln -s /etc/php/php.ini /etc/php/cli/conf.d/99-php.ini\
        && ln -s /etc/php/php.ini /etc/php/fpm/conf.d/99-php.ini\
    &&rm -rf /etc/cron.d\
    &&phpdismod xdebug

COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

COPY --from=builder /tmp/extensions/* /usr/lib/php/${PHP_API_VERSION}/

RUN echo 'extension=swoole.so'>/etc/php/${PHP_VERESION}/mods-available/swoole.ini && phpenmod swoole