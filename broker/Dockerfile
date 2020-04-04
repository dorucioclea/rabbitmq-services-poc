  
#
# Lockdown on rabbitmq version 3.8.3
#
ARG RABBIT_VERSION=3.8.3

FROM rabbitmq:${RABBIT_VERSION}

COPY /configuration/definitions.json /opt/definitions.json
COPY /configuration/rabbit.config /etc/rabbitmq/rabbitmq.config
COPY /plugins/enabled_plugins /etc/rabbitmq/enabled_plugins

CMD ["rabbitmq-server"]