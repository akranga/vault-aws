FROM alpine

ENV AWS_ACCESS_KEY change-me
ENV AWS_SECRET_KEY change-me
ENV AWS_REGION eu-central-1
ENV VAULT_ADDR http://127.0.0.1:8200

COPY tmp/vault       /usr/bin/vault
COPY config.hcl      /etc/vault/config.hcl
COPY start.sh        /usr/bin/start-vault
COPY apk-install.sh  /usr/bin/apk-install
COPY aws             /aws

RUN chmod 755 /usr/bin/start-vault && \
    chmod 755 /usr/bin/apk-install

RUN apk-install curl && \
    apk-install jq

EXPOSE 8200

ENTRYPOINT ["/usr/bin/start-vault"]
