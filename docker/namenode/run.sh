#!/bin/bash
set -e
# wait for zookeeper ready
while [ $(curl zk1:8080/commands/stat -s | grep -cE "follower|leader") -ne 1 ];do 
    echo .
    sleep 2
done
hdfs --daemon start journalnode
if [ $NN_ID -eq 1 ];then
    echo Y | hdfs namenode -format
    hdfs --daemon start namenode
    echo "namenodestart" >> /b.tag
    # ensure all other namenode is ready
    OLD_IFS="$IFS"
    IFS=" "
    namenodes=($OTHER_NN)
    IFS="$OLD_IFS"
    for namenode in ${namenodes[@]}
    do
        while [ $(ssh nn2 cat /b.tag | grep -cE "^finish$") -ne 1 ];do
            echo .
            sleep 2
        done
    done
    hdfs zkfc -formatZK -nonInteractive
    echo Y | hdfs haadmin -transitionToActive --forcemanual nn1  # why is this not graceful
else
    while [ $(ssh nn1 cat /b.tag | grep -cE "^namenodestart$") -ne 1 ];do
        echo .
        sleep 2
    done
    echo Y | hdfs namenode -bootstrapStandby
    echo Y | hdfs --daemon start namenode
    echo "finish" >> /b.tag
fi

# create foreground process to avoid being killed
echo "a" >> /a.log
tail -f a.log
