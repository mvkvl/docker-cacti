FROM bitnami/minideb
MAINTAINER kami <kami@slink.ws>

RUN export DEBIAN_FRONTEND=noninteractive                                   && \
    echo "deb http://httpredir.debian.org/debian stretch contrib non-free" >   \
    /etc/apt/sources.list.d/non-free.list                                   && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup          && \
    apt-get update                                                          && \
    apt-get install -y --no-install-recommends autoconf automake libtool       \
                                   build-essential help2man libssl-dev         \
                                   libsnmp-base  libmariadbclient-dev-compat   \
                                   libsnmp-dev wget ca-certificates         && \
    cd /opt && wget -q https://www.cacti.net/downloads/cacti-1.1.38.tar.gz  && \
    tar xfz cacti-1.1.38.tar.gz && mv cacti-1.1.38 cacti                    && \
    cd /tmp                                                                 && \
    wget -q https://www.cacti.net/downloads/spine/cacti-spine-1.1.38.tar.gz && \
    tar xfz cacti-spine-1.1.38.tar.gz && cd /tmp/cacti-spine-1.1.38         && \
    autoconf && autoheader && automake && ./configure --prefix=/opt/spine   && \
    make && make install && rm -rf /tmp/*                                   && \
    apt-get remove -y autoconf automake libtool build-essential help2man       \
                      libssl-dev libsnmp-base  libmariadbclient-dev-compat     \
                      libsnmp-dev wget ca-certificates                      && \
    apt-get autoremove -y                                                   && \
    apt-get install -y --no-install-recommends netcat iputils-ping             \
                                   snmp cron nginx php-mysql php-cli php-cgi   \
                                   php-fpm snmpd snmp-mibs-downloader php-ldap \
                                   mariadb-client rrdtool php-xml php-mbstring \
                                   php-gd php-snmp php-gmp                  && \
    apt-get clean && rm -rf /var/lib/apt/lists/*                            && \
    sed  -i "s|export MIBS=|export MIBS=ALL|" /etc/default/snmpd            && \
    sed  -i "s|#rocommunity public  localhost|rocommunity public localhost|" /etc/snmp/snmpd.conf && \
    sed -i "s|'/usr/local/spine/bin/spine'|'/opt/spine/bin/spine'|" /opt/cacti/install/functions.php && \
    mkdir -p /opt/cacti/log/                                                && \
    touch /opt/cacti/log/cacti.log                                          && \
    echo ". /opt/scripts/env.sh" >> /root/.bashrc

COPY ./scripts                    /opt/scripts
COPY ./conf/nginx.default         /etc/nginx/sites-available/default
COPY ./conf/nginx.cacti           /etc/nginx/sites-available/cacti
COPY ./conf/cacti.config.php      /opt/cacti/include/config.php.docker
COPY ./conf/cron.d                /etc/cron.d/cacti

RUN cd /etc/nginx/sites-enabled 2> /dev/null                                       && \
    ln -s /etc/nginx/sites-available/cacti /etc/nginx/sites-enabled/cacti          && \
    cp /opt/cacti/include/config.php /opt/cacti/include/config.php.orig            && \
    cp /opt/cacti/include/config.php.docker /opt/cacti/include/config.php          && \
    chown -R www-data:www-data /opt/cacti && chown -R www-data:www-data /opt/spine && \
    chown -R www-data:www-data /opt/spine

CMD ["/opt/scripts/run/entrypoint.sh"]
