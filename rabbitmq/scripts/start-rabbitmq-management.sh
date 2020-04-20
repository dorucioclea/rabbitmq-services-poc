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

#
# Prepare the client's stuff.
#
cd /home/client

# Generate a private RSA key.
openssl genrsa -out key.pem 2048

# Generate a certificate from our private key.
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$(hostname)/O=client/ -nodes

# Sign the certificate with our CA.
cd /home/testca
openssl ca -config openssl.cnf -in /home/client/req.pem -out /home/client/cert.pem -notext -batch -extensions client_ca_extensions

# Create a key store that will contain our certificate.
cd /home/client
openssl pkcs12 -export -out key-store.p12 -in cert.pem -inkey key.pem -passout pass:roboconf

# Create a trust store that will contain the certificate of our CA.
openssl pkcs12 -export -out trust-store.p12 -in /home/testca/cacert.pem -inkey /home/testca/private/cakey.pem -passout pass:roboconf

# Start Rabbitmq in the background (causes the pid file to be updated)
# Note that the pid file location can be overridden with the rmq 'RABBITMQ_PID_FILE' variable

if [ -z "$CLUSTERED" ]; then
    echo ' Starting normally, not clustered'

    rabbitmq-server &
    RABBIT_PROCESS=$!
    [ $? -ne 0 ] && echo "Rabbitmq failed to start!" && \
        rm -f /var/lib/rabbitmq/mnesia/$RABBITMQ_NODENAME.pid && exit 1

    #
    # Wait non blocking.
    #
    # Unlike the sleep command, wait allows to react (trap) to signals
    #
    wait $RABBIT_PROCESS
else 
    if [ -z "$CLUSTER_WITH" ]; then
        # If clustered, but cluster with is not specified then again start normally, could be the first server in the
		# cluster

        echo " No cluster_with, must be master"

        rabbitmq-server &
        RABBIT_PROCESS=$!
        [ $? -ne 0 ] && echo "Rabbitmq failed to start!" && \
            rm -f /var/lib/rabbitmq/mnesia/$RABBITMQ_NODENAME.pid && exit 1

        #
        # Wait non blocking.
        #
        # Unlike the sleep command, wait allows to react (trap) to signals
        #
        wait $RABBIT_PROCESS
    else 
        echo " Clustered, starting as slave "
        rabbitmq-server &
        echo " Started server "
		rabbitmqctl wait /var/lib/rabbitmq/mnesia/$RABBITMQ_NODENAME.pid
        echo " Waited successfully for rabbitmq process on node $RABBITMQ_NODENAME"
        rabbitmqctl stop_app
        if [ -z "$RAM_NODE" ]; then
            rabbitmqctl join_cluster $CLUSTER_WITH
        else
            rabbitmqctl join_cluster --ram $CLUSTER_WITH
        fi

        rabbitmqctl start_app
        # Tail to keep the a foreground process active..
		tail -f /dev/null
    fi
fi



    # rabbitmq-server &
    # RABBIT_PROCESS=$!
    # [ $? -ne 0 ] && echo "Rabbitmq failed to start!" && \
    #     rm -f /var/lib/rabbitmq/mnesia/$RABBITMQ_NODENAME.pid && exit 1

    #
    # Wait non blocking.
    #
    # Unlike the sleep command, wait allows to react (trap) to signals
    #
    wait $RABBIT_PROCESS