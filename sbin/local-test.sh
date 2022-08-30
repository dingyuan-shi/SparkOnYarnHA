#!/bin/bash

DIR=$(dirname $0)

if [[ -z $SPARK_HOME ]];then
  echo "must set SPARK_HOME"
fi

MAIN_CLASS=$1
if [[ -z $MAIN_CLASS ]];then
  echo "must set main class"
  exit 1
fi
shift 1

mvn package
$SPARK_HOME/bin/spark-submit --master "local[2]" --class "$MAIN_CLASS" "$DIR"/target/learn-1.0.jar $@