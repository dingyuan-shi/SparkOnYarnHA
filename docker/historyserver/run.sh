#!/bin/bash

# ensure all datanodes are ready
OLD_IFS="$IFS"
IFS=" "
datanodes=($DATANODES)
IFS="$OLD_IFS"
for datanode in ${datanodes[@]}
do
    while [ `ssh $datanode cat /a.log | grep -cE "^a$"` -ne 1 ]; do
        echo .
        sleep 5
    done
done

start-history-server.sh
mapred --daemon start historyserver
echo "a" > /a.log
tail -f /a.log