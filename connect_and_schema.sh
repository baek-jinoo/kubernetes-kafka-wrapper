#!/usr/bin/env bash
set -ex

rm cp-helm-charts-0.1.1.tgz || true
helm package cp-helm-charts/
helm install --set cp-schema-registry.enabled=true,cp-kafka-rest.enabled=false,cp-kafka-connect.enabled=true,cp-kafka.enabled=false,cp-zookeeper.enabled=false,cp-ksql-server.enabled=false,cp-control-center.enabled=false cp-helm-charts-0.1.1.tgz --tls --namespace kafka

