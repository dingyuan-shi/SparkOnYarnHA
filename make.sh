#!/bin/bash
DIR="`dirname $0`"

case $1 in
    "clean")
        # clear old containers
        docker rm -f $(docker ps -a | grep -E "hdfs/namenode|hdfs/datanode|yarn/resourcemanager|zookeeper|env/sparkclient" | awk '{print $1}')
        if [ "$2a" = "-fa" ]; then
            # clear old images
            docker rmi -f hdfs/namenode hdfs/datanode yarn/resourcemanager env/sparkclient env/hadoop env/base
            # clear old volumes
            docker volume prune -f
            rm -rf $DIR/runData
        fi
    ;;
    "build")
        set -e
        # distributed confs and resources
        cp $DIR/conf/ssh/ssh_config $DIR/docker/base/
        cp $DIR/conf/hadoop/*.xml $DIR/docker/hadoop/
        cp $DIR/conf/zookeeper.env $DIR/docker/
        cp $DIR/conf/spark/spark-defaults.conf $DIR/docker/sparkclient
        cp $DIR/conf/spark/spark-env.sh $DIR/docker/sparkclient

        # build new images
        docker build -t env/base $DIR/docker/base
        docker build -t env/hadoop $DIR/docker/hadoop
        docker build -t env/sparkclient $DIR/docker/sparkclient
        docker build -t hdfs/namenode $DIR/docker/namenode
        docker build -t hdfs/datanode $DIR/docker/datanode
        docker build -t yarn/resourcemanager $DIR/docker/resourcemanager
        docker build -t yarn/nodemanager $DIR/docker/nodemanager

        rm $DIR/docker/base/ssh_config \
            $DIR/docker/hadoop/*.xml \
            $DIR/docker/sparkclient/spark-defaults.conf  \
            $DIR/docker/sparkclient/spark-env.sh
    ;;
    "gen")  python $DIR/conf/generator.py
    ;;
    "up")
        python $DIR/conf/generator.py
        docker-compose -f $DIR/docker/docker-compose.yml --compatibility up
    ;;
    *)  echo "illegal argument, please use fetch|clean [-f]|build|gen|up"
    ;;
esac