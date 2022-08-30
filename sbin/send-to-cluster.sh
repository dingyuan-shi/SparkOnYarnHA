#!/bin/bash

DIR=$(dirname "$0")
DEPLOY_PATH=/path/to/your/deploy/
SRC_DATA_PATH=/path/to/data/
EXCHANGE_DATA_PATH="$DEPLOY_PATH"/exchange/data
EXCHANGE_CODE_PATH="$DEPLOY_PATH"/exchange/code

if [[ -z $1 ]];then
    echo "must specify main class name"
    exit 1
fi
MAIN_CLASS="$1"
shift 1
# transfer data
cp $SRC_DATA_PATH/*  $EXCHANGE_DATA_PATH
# upload data to hdfs
docker exec -i dn1 hadoop fs -put /data/ /
# generate jar
mvn package
# get jar name
JAR_WITHOUT_DEPENDENCIES=$(ls "$DIR"/target/ | grep -E "[0-9]\.jar")
# transfer jar
cp "$DIR"/target/"$JAR_WITHOUT_DEPENDENCIES" $EXCHANGE_CODE_PATH/
docker exec -i sc spark-submit --class "$MAIN_CLASS" --master yarn --deploy-mode cluster /jars/"$JAR_WITHOUT_DEPENDENCIES" "$@"