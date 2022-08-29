#!/bin/bash
DIR="`dirname $0`"

case $1 in
    "clean")
        # clear old containers
        docker rm -f $(docker ps -a | grep -E "hdfs/namenode|hdfs/datanode|yarn/resourcemanager|yarn/nodemanager|zookeeper|spark/sparkclient|spark/historyserver|env/spark|env/hadoop|env/base" | awk '{print $1}')
        if [ "$2a" = "-fa" ]; then
            # clear old images
            docker rmi -f hdfs/namenode hdfs/datanode yarn/resourcemanager yarn/nodemanager spark/sparkclient spark/historyserver env/spark env/hadoop env/base
            # clear old volumes
            docker volume prune -f
            rm -rf $DIR/runData
        fi
    ;;
    "build")
        set -e
        python $DIR/conf/generator.py
        # distributed confs and resources
        cp $DIR/conf/ssh/ssh_config $DIR/docker/base/
        cp $DIR/conf/hadoop/*.xml $DIR/docker/hadoop/
        cp $DIR/conf/zookeeper.env $DIR/docker/
        cp $DIR/conf/spark/spark-defaults.conf $DIR/docker/spark
        cp $DIR/conf/spark/spark-env.sh $DIR/docker/spark

        # build new images
        docker build -t env/base $DIR/docker/base
        docker build -t env/hadoop $DIR/docker/hadoop
        
        docker build -t hdfs/namenode $DIR/docker/namenode
        docker build -t hdfs/datanode $DIR/docker/datanode
        docker build -t yarn/resourcemanager $DIR/docker/resourcemanager
        docker build -t yarn/nodemanager $DIR/docker/nodemanager
        
        
        docker build -t env/spark $DIR/docker/spark
        docker build -t spark/sparkclient $DIR/docker/sparkclient
        docker build -t spark/historyserver $DIR/docker/historyserver

        rm $DIR/docker/base/ssh_config \
            $DIR/docker/hadoop/*.xml \
            $DIR/docker/spark/spark-defaults.conf  \
            $DIR/docker/spark/spark-env.sh
    ;;
    "gen")  python $DIR/conf/generator.py
    ;;
    "up")
        docker-compose -f $DIR/docker/docker-compose.yml --compatibility up
    ;;
    *)  echo "illegal argument, please use: clean [-f]|build|gen|up"
    ;;
esac