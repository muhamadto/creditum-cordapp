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

BUILD_DIR=./target
WORKING_DIR=$BUILD_DIR/nodes
NETWORK_BOOTSTRAPPER=$WORKING_DIR/network-bootstrapper.jar
CORDA_APP_DIR=$3
DOCKER_COMPOSE_FILE=./docker-compose.yml

# Remove old files first
echo "Remove old artifacts"
rm -R $WORKING_DIR/shared
rm -R $WORKING_DIR/notary
rm -R $WORKING_DIR/bank
rm -R $WORKING_DIR/corporation
rm -R $WORKING_DIR/hedge-fund
rm -R $WORKING_DIR/.cache
rm  $WORKING_DIR/*.conf
rm  $WORKING_DIR/docker-compose.yml

# Create node file structure
echo "Bootstrapping Corda Network"
create_directory $WORKING_DIR
cp *.conf $WORKING_DIR

if [ ! -f $NETWORK_BOOTSTRAPPER ]; then
  curl -H "Accept: application/zip" https://software.r3.com/artifactory/corda-releases/net/corda/corda-tools-network-bootstrapper/4.4/corda-tools-network-bootstrapper-4.4.jar > $NETWORK_BOOTSTRAPPER
fi

# Pull down helper cordapps
if [ ! -f $BUILD_DIR/corda-finance-contracts.jar ]; then
  curl -H "Accept: application/zip" https://repo1.maven.org/maven2/net/corda/corda-finance-contracts/4.4/corda-finance-contracts-4.4.jar > $BUILD_DIR/corda-finance-contracts.jar
fi

if [ ! -f $BUILD_DIR/corda-finance-workflows.jar ]; then
  curl -H "Accept: application/zip" https://repo1.maven.org/maven2/net/corda/corda-finance-workflows/4.4/corda-finance-workflows-4.4.jar > $BUILD_DIR/corda-finance-workflows.jar
fi

create_corda_nodes_file_structure $NETWORK_BOOTSTRAPPER $WORKING_DIR

# Create shared directory
create_directory $WORKING_DIR/shared
create_directory $WORKING_DIR/shared/cordapps

# Move network-parameters to shared directory
echo "current dir `pwd`"
cp $WORKING_DIR/notary/network-parameters $WORKING_DIR/shared
rm $WORKING_DIR/notary/network-parameters
rm $WORKING_DIR/bank/network-parameters
rm $WORKING_DIR/corporation/network-parameters
rm $WORKING_DIR/hedge-fund/network-parameters

# Move additional-node-infos to shared directory
cp -R $WORKING_DIR/notary/additional-node-infos $WORKING_DIR/shared
rm -R $WORKING_DIR/notary/additional-node-infos
rm -R $WORKING_DIR/bank/additional-node-infos
rm -R $WORKING_DIR/corporation/additional-node-infos
rm -R $WORKING_DIR/hedge-fund/additional-node-infos

# Move cordapp to shared directory
cp $BUILD_DIR/creditum-cordapp*.jar $WORKING_DIR/shared/cordapps/

# Copy helper cordapps to shared directory
cp $BUILD_DIR/corda-finance-contracts.jar $WORKING_DIR/shared/cordapps/corda-finance-contracts.jar
cp $BUILD_DIR/corda-finance-workflows.jar $WORKING_DIR/shared/cordapps/corda-finance-workflows.jar

# Copy  docker compose to $WORKING_DIR
echo "Copy docker compose file '$DOCKER_COMPOSE_FILE'"
cp $DOCKER_COMPOSE_FILE $WORKING_DIR/docker-compose.yml

# clean up
rm -R ./*.log

# spin nodes up
cd $WORKING_DIR
docker-compose up
