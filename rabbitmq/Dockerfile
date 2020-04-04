  
#
# Lockdown on rabbitmq version 3.8.3
#
ARG RABBIT_VERSION=3.8.3

FROM rabbitmq:${RABBIT_VERSION}-management

RUN apk add \
    tini=0.18.0-r0 \
    supervisor \
    dos2unix \
    --no-cache  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

COPY config/enabled_plugins /etc/rabbitmq/enabled_plugins
COPY config/rabbitmq-env.conf /etc/rabbitmq/rabbitmq-env.conf
COPY config/rabbitmq-modified.conf /etc/rabbitmq/rabbitmq-modified.conf
COPY config/rabbitmq-definitions.json /etc/rabbitmq/rabbitmq-definitions.json
COPY scripts/start-rabbitmq-management.sh /usr/bin/start-rabbitmq-management.sh


RUN dos2unix /usr/bin/start-rabbitmq-management.sh
RUN chmod +x /usr/bin/start-rabbitmq-management.sh

# CMD ["rabbitmq-server"]