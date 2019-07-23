#!/usr/bin/env bash
set -ex

kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: mysql-cluster
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: mysql-cluster
  labels:
    app: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: debezium/example-mysql:0.9
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "debezium"
        - name: MYSQL_USER
          value: "mysqluser"
        - name: MYSQL_PASSWORD
          value: "mysqlpw"
        ports:
        - containerPort: 3306

---
apiVersion: v1
kind: Service
metadata:
  namespace: mysql-cluster
  name: mysql
spec:
  selector:
    app: mysql
  ports:
  - protocol: TCP
    port: 3306
    targetPort: 3306
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu
  namespace: kafka
spec:
  containers:
  - name: ubuntu
    image: ubuntu:16.04
    command:
      - sh
      - -c
      - "exec tail -f /dev/null"
EOF


kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: kafka-client
  namespace: kafka
spec:
  containers:
  - name: kafka-client
    image: confluentinc/cp-kafka:5.0.1
    command:
      - sh
      - -c
      - "exec tail -f /dev/null"
EOF

