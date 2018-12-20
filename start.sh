#!/bin/bash

stop_requested=false
trap "stop_requested=true" TERM INT

wait_signal() {
    while ! $stop_requested; do
        sleep 1
    done
}

wait_exit() {
    while pidof $1; do
        sleep 1
    done
}

chown -R www-data:www-data /var/www/

if [ ! -s /etc/apache2/magic ]; then
    cp -r /etc/apache2-orig/* /etc/apache2/
fi

service apache2 start

wait_signal

echo "Try to exit properly"
service apache2 stop

wait_exit "apache2"
