#!/bin/bash

function create_directory() {
  TARGET_DIR="$1"

  echo "Creating directory '$TARGET_DIR'"

  if [ ! -d "$(pwd)/$TARGET_DIR" ]; then
    mkdir "$TARGET_DIR"
  fi
}

function create_corda_nodes_file_structure() {
  echo "Creating corda nodes file structure under directory '$2' using bootstrapper '$1'"
  java -jar $1 --dir $2
}

NETWORK_BOOTSTRAPPER=$1
WORKING_DIR=$2
CORDA_APP_DIR=$3
DOCKER_COMPOSE_FILE=$4

# Remove old files first
echo "Bootstrapping Corda Network"
echo "Remove old artifacts"
rm -R $WORKING_DIR/shared
rm -R $WORKING_DIR/pecunia-notary
rm -R $WORKING_DIR/pecunia-supplier
rm -R $WORKING_DIR/pecunia-consumer
rm  $WORKING_DIR/docker-compose.yml


# Create node file structure
create_directory $WORKING_DIR
create_corda_nodes_file_structure $NETWORK_BOOTSTRAPPER $WORKING_DIR

# Create shared directory
create_directory $WORKING_DIR/shared
create_directory $WORKING_DIR/shared/cordapps

# Move network-parameters to shared directory
echo "current dir `pwd`"
cp -R $WORKING_DIR/pecunia-notary/network-parameters $WORKING_DIR/shared
rm -R $WORKING_DIR/pecunia-notary/network-parameters
rm -R $WORKING_DIR/pecunia-supplier/network-parameters
rm -R $WORKING_DIR/pecunia-consumer/network-parameters

# Move additional-node-infos to shared directory
cp -R $WORKING_DIR/pecunia-notary/additional-node-infos $WORKING_DIR/shared
rm -R $WORKING_DIR/pecunia-notary/additional-node-infos
rm -R $WORKING_DIR/pecunia-supplier/additional-node-infos
rm -R $WORKING_DIR/pecunia-consumer/additional-node-infos

# Move cordapp to shared directory
cp $CORDA_APP_DIR/*.jar $WORKING_DIR/shared/cordapps/

# Copy  docker compose to $WORKING_DIR
echo "Copy docker compose file '$DOCKER_COMPOSE_FILE'"
cp $DOCKER_COMPOSE_FILE $WORKING_DIR/docker-compose.yml

# clean up
rm *.log

# spin nodes up
cd $WORKING_DIR
docker-compose up

