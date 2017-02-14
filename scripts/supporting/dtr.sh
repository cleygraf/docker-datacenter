#!/bin/bash
echo ""
echo "=============================================================="
echo "=============================================================="
echo ""
echo "$0 started"
echo ""

# get ucp certs
curl -k https://$UCP_URL/ca > ucp-ca.pem

docker run --rm \
    docker/dtr install \
    --ucp-url $UCP_URL \
    --ucp-ca "$(cat ucp-ca.pem)" \
    --ucp-username $UCP_USER --ucp-password $UCP_PASSWORD \
    --dtr-external-url $DTR_PUBLIC_IP:${DTR_HTTPS_PORT} \
    --replica-http-port ${DTR_HTTP_PORT} \
    --replica-https-port ${DTR_HTTPS_PORT}
sleep 20

# some inspiration taken from:
# https://blog.docker.com/2016/04/docker-datacenter-ddc-in-a-box/

# reconfigure dtr to work with a specific ssl
source ${SCRIPT_PATH}/scripts/supporting/dtr-ssl.sh

# configure ucp
echo ""
echo ""
echo "=============================================================="
echo "Configuring UCP to use DTR"
echo ""
TOKEN=$(curl -k -c jar https://${UCP_URL}/auth/login -d '{"username": "admin", "password": "orca1234"}' -X POST -s | ./jq-linux64 -r ".auth_token")
echo "TOKEN: ${TOKEN}"
curl -k -s -c jar -H "Authorization: Bearer ${TOKEN}" https://${UCP_URL}/api/config/registry -X POST --data "{\"url\": \"https://${DTR_URL}\", \"insecure\":false}"

# make the ucp cert bundle available on the host
curl -k -s -H "Authorization: Bearer ${TOKEN}" https://${UCP_URL}/api/clientbundle -X POST > ~/admin_bundle.zip
echo ""
echo "Finished configuring UCP to use DTR"
echo "=============================================================="

# push image
source ${SCRIPT_PATH}/scripts/supporting/dtr-push-image.sh

echo ""
echo "$0 finished"
echo ""
echo "=============================================================="
echo "=============================================================="
echo ""
