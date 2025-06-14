#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io

systemctl enable docker
systemctl start docker

docker run -d --restart=always --name rabbitmq \
  -p 5672:5672 -p 15672:15672 \
  rabbitmq:3.12-management
