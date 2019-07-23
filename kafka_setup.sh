#!/usr/bin/env bash
set -ex

kubectl apply -f -<<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: kafka
EOF

curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.12.1/strimzi-cluster-operator-0.12.1.yaml \
  | sed 's/namespace: .*/namespace: kafka/' \
  | kubectl -n kafka apply -f -


BROKER_REPLICAS_COUNT=${BROKER_REPLICAS_COUNT:-3}
ZOOKEEPER_REPLICAS_COUNT=${ZOOKEEPER_REPLICAS_COUNT:-3}

kubectl apply -n kafka -f -<<EOF
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 2.2.1
    replicas: ${BROKER_REPLICAS_COUNT}
    listeners:
      plain: {}
      tls: {}
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: "2.2"
    storage:
      type: jbod
      volumes:
      - id: 0
        type: persistent-claim
        size: 100Gi
        deleteClaim: false
  zookeeper:
    replicas: ${ZOOKEEPER_REPLICAS_COUNT}
    storage:
      type: persistent-claim
      size: 100Gi
      deleteClaim: false
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF

