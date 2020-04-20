  
#
# Lockdown on rabbitmq version 3.8.3
#
ARG RABBIT_VERSION=3.8.3

FROM rabbitmq:3-management-alpine

RUN apk add \
    tini=0.18.0-r0 \
    supervisor \
    openssl \
    dos2unix \
    --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

RUN mkdir -p /home/testca/certs \
	&& mkdir -p /home/testca/private \
	&& chmod 700 /home/testca/private \
	&& echo 01 > /home/testca/serial \
	&& touch /home/testca/index.txt



RUN mkdir -p /home/server
RUN mkdir -p /home/client
RUN mkdir /ssl-certs

COPY config/enabled_plugins /etc/rabbitmq/enabled_plugins
COPY config/rabbitmq-env.conf /etc/rabbitmq/rabbitmq-env.conf
COPY config/rabbitmq-modified.conf /etc/rabbitmq/rabbitmq-modified.conf	
COPY config/definitions.json /etc/rabbitmq/rabbitmq-definitions.json

COPY scripts/start-rabbitmq-management.sh /usr/bin/start-rabbitmq-management.sh
COPY scripts/prepare-ssl.sh /home/prepare-ssl.sh
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf

RUN dos2unix /usr/bin/start-rabbitmq-management.sh
RUN dos2unix /home/prepare-ssl.sh
RUN chmod +x /usr/bin/start-rabbitmq-management.sh
RUN chmod +x /home/prepare-ssl.sh

# COPY ssl-certs/ /ssl-certs
COPY config/openssl.cnf /home/testca

RUN /home/prepare-ssl.sh


ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 4369 5671 5672 25672