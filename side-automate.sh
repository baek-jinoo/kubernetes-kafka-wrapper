#!/usr/bin/env bash
set -ex

./cluster_setup.sh
./helm_setup.sh
./connect_and_schema.sh
#./quick_test.sh
