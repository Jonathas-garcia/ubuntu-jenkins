#!/bin/bash
set -e
echo "Starting Jenkins..."
service jenkins start
echo "Setting permissions to docker.sock..."
chmod 777 var/run/docker.sock
echo "Setting permissions to jenkins user..."
echo "jenkins ALL= NOPASSWD: ALL" >> /etc/sudoers
exec "$@";
