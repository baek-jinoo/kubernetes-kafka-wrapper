#!/usr/bin/env bash
set -ex

kubectl --namespace kafka apply -k ./kubernetes-kafka/cruise-control/
kubectl --namespace kafka patch statefulset my-cluster-kafka --patch "$(cat kubernetes-kafka/cruise-control/20kafka-broker-reporter-patch.yml)"
kubectl exec -it my-cluster-zookeeper-0 -n kafka -- bin/kafka-topics.sh --zookeeper localhost:21810 --create --if-not-exists --topic __CruiseControlMetrics --partitions '12' --replication-factor '3'

