#!/bin/sh -xe
IP=172.31.14.159
DOCKER_IP=172.17.42.1
AWS_CREDS_FILE=~/.aws/credentials
AWS_CONFIG_FILE=~/.aws/config
AWS_ACCOUNT=default

AWS_ACCESS_KEY=$(awk '/^aws_access_key_id/{print $3;exit}' "${AWS_CREDS_FILE}")
AWS_SECRET_KEY=$(awk '/^aws_secret_access_key/{print $3;exit}' "${AWS_CREDS_FILE}")
AWS_REGION=$(awk '/^region/{print $3;exit}' "${AWS_CONFIG_FILE}")

docker kill vault | true
docker kill consul | true
docker rm consul | true
docker rm consul-data | true
docker rm vault | true

#docker pull alpine
docker create -v /consul-data --name consul-data alpine /bin/true | true

docker run -p 8300:8300 -p 8301:8301 -p $IP:8301:8301/udp -p 8302:8302 -p $IP:8302:8302/udp -p 8400:8400 -p 8500:8500 -p $DOCKER_IP:53:53/udp -d --name consul -h node1 --volumes-from=consul-data gliderlabs/consul-server -advertise $IP -bootstrap-expect 1 -data-dir /consul-data

#docker run -e AWS_ACCESS_KEY= -e AWS_SECRET_KEY= -d --link=consul:consul --privileged akranga/vault

docker run -d --name=vault -e AWS_ACCESS_KEY=$AWS_ACCESS_KEY -e AWS_SECRET_KEY=$AWS_SECRET_KEY -e AWS_REGION=$AWS_REGION --link=consul:consul --privileged akranga/vault
# docker run --name consul -d --restart=always -i -t -e SERVICE_IGNORE=true --volumes-from=consul-data -h node1 -p 8301:8301/udp -p 8301:8301/tcp -p 8302:8302/udp -p 8302:8302/tcp -p 8400:8400 -p 8500:8500/tcp -p 8300:8300/tcp -p 8300:8300/udp -p 53:53/udp -p 53:53/tcp gliderlabs/consul agent -data-dir="/consul-data" -server -bootstrap -ui-dir /ui§
