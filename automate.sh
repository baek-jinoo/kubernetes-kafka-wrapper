#!/usr/bin/env bash
set -ex

./cluster_setup.sh
./kafka_setup.sh
#./cruise_control.sh
./helm_setup.sh
./connect_and_schema.sh
