#!/bin/sh -xe

sed -e "s|{{consul_addr}}|$CONSUL_PORT_8500_TCP_ADDR|" \
     -e "s|{{consul_port}}|$CONSUL_PORT_8500_TCP_PORT|" \
     -i /etc/vault/config.hcl

vault server -config=/etc/vault/config.hcl 2> /dev/stderr > /dev/stdout &
VAULT_PID=$!
echo "Vault is starting up"
sleep 3
curl -o /vault-unseal-keys.json -X PUT -d "{\"secret_shares\":3, \"secret_threshold\":3}" $VAULT_ADDR/v1/sys/init

UNSEAL_KEYS=$(cat /vault-unseal-keys.json | jq -r .keys[])
for KEY in $UNSEAL_KEYS; do
  vault unseal $KEY
done

ROOT_TOKEN=$(cat /vault-unseal-keys.json | jq -r .root_token)
vault auth $ROOT_TOKEN

vault mount aws
vault write aws/config/root access_key=$AWS_ACCESS_KEY secret_key=$AWS_SECRET_KEY region=$AWS_REGION

for policy in /aws/*; do
  POLICY_NAME=$(basename $policy .json)
  vault write aws/roles/$POLICY_NAME name=$POLICY_NAME policy=@$policy
done
 
wait $VAULT_PID

