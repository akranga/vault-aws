#!/bin/sh -xe

IMAGE=akranga/vault-aws
VAULT_VERSION=0.2.0

mkdir tmp/ | true
wget -O tmp/vault.zip https://dl.bintray.com/mitchellh/vault/vault_$(echo $VAULT_VERSION)_linux_amd64.zip
unzip -o tmp/vault.zip -d tmp/

docker build --no-cache --force-rm -t $IMAGE .
ID=$(sudo docker images $IMAGE | grep latest | awk '{print $3}')
docker tag -f $ID $IMAGE:$VAULT_VERSION
