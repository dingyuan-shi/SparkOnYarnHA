#!/bin/bash
DIR="`dirname $0`"

case $1 in
    "fetch")
        # fetch hadoop 3.2.3
        [ -f $DIR/resources/hadoop-3.2.3.tar.gz ] || wget https://mirrors.aliyun.com/apache/hadoop/common/hadoop-3.2.3/hadoop-3.2.3.tar.gz  \
            -O $DIR/resources/hadoop-3.2.3.tar.gz
        # fetch spark 3.3.0
        [ -f $DIR/resources/spark-3.3.0-bin-without-hadoop.tgz ] || wget https://mirrors.aliyun.com/apache/spark/spark-3.3.0/spark-3.3.0-bin-without-hadoop.tgz  \
            -O $DIR/resources/spark-3.3.0-bin-without-hadoop.tgz
        # fetch jdk
        [ -f $DIR/resources/openlogic-openjdk-8u262-b10-linux-x64.tar.gz ] || wget https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u262-b10/openlogic-openjdk-8u262-b10-linux-x64.tar.gz  \
            -O $DIR/resources/openlogic-openjdk-8u262-b10-linux-x64.tar.gz
    ;;
    "clean")
        # clear old containers
        docker rm -f $(docker ps -a | grep -E "hdfs/namenode|hdfs/datanode|yarn/resourcemanager|zookeeper|env/sparkclient" | awk '{print $1}')
        if [ "$2a" = "fa" ]; then
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
        cp $DIR/resources/openlogic-openjdk-8u262-b10-linux-x64.tar.gz $DIR/docker/base
        cp $DIR/conf/hadoop/*.xml $DIR/docker/hadoop/
        cp $DIR/resources/hadoop-3.2.3.tar.gz $DIR/docker/hadoop/
        cp $DIR/resources/spark-3.3.0-bin-without-hadoop.tgz $DIR/docker/sparkclient
        cp $DIR/conf/zookeeper.env $DIR/docker/
        cp $DIR/conf/spark/spark-defaults.conf $DIR/docker/sparkclient
        cp $DIR/conf/spark/spark-env.sh $DIR/docker/sparkclient

        # build new images
        docker build -t env/base $DIR/docker/base
        docker build -t env/hadoop $DIR/docker/hadoop
        docker build -t hdfs/namenode $DIR/docker/namenode
        docker build -t hdfs/datanode $DIR/docker/datanode
        docker build -t yarn/resourcemanager $DIR/docker/resourcemanager
        docker build -t env/sparkclient $DIR/docker/sparkclient

        rm $DIR/docker/base/ssh_config $DIR/docker/base/openlogic-openjdk-8u262-b10-linux-x64.tar.gz \
            $DIR/docker/hadoop/*.xml $DIR/docker/hadoop/hadoop-3.2.3.tar.gz \
            $DIR/docker/sparkclient/spark-3.3.0-bin-without-hadoop.tgz  \
            $DIR/docker/sparkclient/spark-defaults.conf  \
            $DIR/docker/sparkclient/spark-env.sh
    ;;
    "gen")  echo "TODO: gen docker-compose based on conf"
    ;;
    "up")
        docker-compose -f $DIR/docker/docker-compose.yml --compatibility up
    ;;
    *)  echo "illegal argument, please use fetch|clean [-f]|build|gen|up"
    ;;
esac