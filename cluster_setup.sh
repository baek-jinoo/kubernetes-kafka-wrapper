#!/usr/bin/env bash
set -ex

PROJECT_ID=${PROJECT_ID:-quizlet-data-services}
ZONE_ID=${ZONE_ID:-us-central1-c}
REGION_ID=${REGION_ID:-us-central1}
CLUSTER_NAME=${CLUSTER_NAME:-cluster-name-1}
CLUSTER_VERSION=${CLUSTER_VERSION:-1.12.8-gke.10}
NODE_LOCATIONS=${NODE_LOCATIONS:-us-central1-a,us-central1-c,us-central1-f}
PRODUCTION=${PRODUCTION:-0}

if [ "$PRODUCTION" -ne "1" ]
then
  STANDARD_DISK_SIZE=240
  SSD_DISK_SIZE=80
  MIN_NODES_PER_POOL=1
  MAX_NODES_PER_POOL=5
  START_NUM_NODES_PER_POOL=1
  MAIN_POOL_MACHINE_TYPE="n1-standard-2"
  POOL_1_MACHINE_TYPE="n1-standard-4"
  NETWORK="projects/quizlet-data-services/global/networks/jin-experiment"
  SUBNETWORK="projects/quizlet-data-services/regions/${REGION_ID}/subnetworks/jin-experiment"
else
  START_NUM_NODES_PER_POOL=3
  MIN_NODES_PER_POOL=3
  MAX_NODES_PER_POOL=15
  STANDARD_DISK_SIZE=400
  SSD_DISK_SIZE=400
  MAIN_POOL_MACHINE_TYPE="n1-standard-2"
  POOL_1_MACHINE_TYPE="n1-standard-4"
  NETWORK="projects/quizlet-data-services/global/networks/k8s-default"
  SUBNETWORK="projects/quizlet-data-services/regions/${REGION_ID}/subnetworks/k8s-default"
fi

gcloud config set project "$PROJECT_ID"
gcloud config set compute/zone "$ZONE_ID"

gcloud beta container --project "quizlet-data-services" \
  clusters create ${CLUSTER_NAME} \
  --region ${REGION_ID} \
  --no-enable-basic-auth \
  --cluster-version "1.12.8-gke.10" \
  --machine-type ${MAIN_POOL_MACHINE_TYPE} \
  --image-type "COS" \
  --disk-type "pd-standard" \
  --disk-size ${STANDARD_DISK_SIZE} \
  --node-locations ${NODE_LOCATIONS} \
  --network ${NETWORK} \
  --subnetwork ${SUBNETWORK} \
  --metadata disable-legacy-endpoints=true \
  --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
  --num-nodes ${START_NUM_NODES_PER_POOL} \
  --enable-cloud-logging \
  --enable-cloud-monitoring \
  --no-enable-ip-alias \
  --enable-autoscaling \
  --min-nodes ${MIN_NODES_PER_POOL} \
  --max-nodes ${MAX_NODES_PER_POOL} \
  --addons HorizontalPodAutoscaling,HttpLoadBalancing \
  --enable-autoupgrade \
  --enable-autorepair \
  --maintenance-window "10:00" \
  && gcloud beta container --project ${PROJECT_ID} \
  node-pools create "pool-1" \
  --cluster ${CLUSTER_NAME} \
  --region ${REGION_ID} \
  --node-version "1.12.8-gke.10" \
  --machine-type ${POOL_1_MACHINE_TYPE} \
  --image-type "COS" \
  --disk-type "pd-ssd" \
  --disk-size ${SSD_DISK_SIZE} \
  --enable-autoscaling \
  --min-nodes ${MIN_NODES_PER_POOL} \
  --max-nodes ${MAX_NODES_PER_POOL} \
  --metadata disable-legacy-endpoints=true \
  --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
  --num-nodes ${START_NUM_NODES_PER_POOL} \
  --enable-autoupgrade \
  --enable-autorepair


gcloud container clusters get-credentials ${CLUSTER_NAME} --project ${PROJECT_ID} --region ${REGION_ID}

