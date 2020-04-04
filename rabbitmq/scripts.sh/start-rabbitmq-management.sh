#!/bin/sh


function cleanup_on_exit() {
    echo "Stopping rabbitmq"
      rabbitmqctl stop
}

#
# Trap SIGTERM and SIGINT and execute 
#
# Run the "stop" command when receiving SIGNAL
trap "cleanup_on_exit" TERM KILL HUP INT SIGTERM SIGKILL SIGHUP SIGINT
trap "cleanup_on_exit" EXIT


# Start Rabbitmq in the background (causes the pid file to be updated)
# Note that the pid file location can be overridden with the rmq 'RABBITMQ_PID_FILE' variable
/usr/sbin/rabbitmq-server &
RABBIT_PROCESS=$!

rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
echo "RabbitMQ Started"

[ $? -ne 0 ] && echo "Rabbitmq failed to start!" && \
    rm -f /var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid && exit 1

#
# Wait non blocking.
#
# Unlike the sleep command, wait allows to react (trap) to signals
#
wait $RABBIT_PROCESS
