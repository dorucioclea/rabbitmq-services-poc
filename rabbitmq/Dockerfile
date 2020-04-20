  
#
# Lockdown on rabbitmq version 3.8.3
#
ARG RABBIT_VERSION=3.8.3

FROM rabbitmq:3-management-alpine

RUN apk add \
    tini=0.18.0-r0 \
    supervisor \
    dos2unix \
    --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

COPY config/enabled_plugins /etc/rabbitmq/enabled_plugins
COPY config/rabbitmq.config /etc/rabbitmq/rabbitmq.config
COPY config/definitions.json /etc/rabbitmq/definitions.json
COPY config/erlang.cookie /var/lib/rabbitmq/.erlang.cookie


COPY scripts/start-rabbitmq-management.sh /usr/bin/start-rabbitmq-management.sh
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf

RUN dos2unix /usr/bin/start-rabbitmq-management.sh
RUN chmod +x /usr/bin/start-rabbitmq-management.sh

ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 4369 5671 5672 25672