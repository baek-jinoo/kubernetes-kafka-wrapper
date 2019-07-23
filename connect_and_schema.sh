#!/usr/bin/env bash
set -ex

rm cp-helm-charts-0.1.1.tgz || true
helm package cp-helm-charts/
FILE=./secrets/pubsub-secret.json
if test -f "$FILE"; then
  echo "$FILE exists, great!"
else
  echo "$FILE does not exist. Please add a secret json file for a service account with pubsub admin privileges"
  exit 1;
fi
kubectl create secret generic pubsub-key-subscriber -n kafka --from-file=key.json=$FILE || true
helm install --set cp-schema-registry.enabled=true,cp-kafka-rest.enabled=false,cp-kafka-connect.enabled=true,cp-kafka.enabled=false,cp-zookeeper.enabled=false,cp-ksql-server.enabled=false,cp-control-center.enabled=false cp-helm-charts-0.1.1.tgz --tls --namespace kafka

