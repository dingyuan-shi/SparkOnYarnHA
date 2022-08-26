#!/bin/bash

# ensure all resource managers are ready
OLD_IFS="$IFS"
IFS=" "
resourcemanagers=($RESOURCEMANAGERS)
IFS="$OLD_IFS"
for resourcemanager in ${resourcemanagers[@]}
do
    while [ `ssh $resourcemanager cat /a.log | grep -cE "^a$"` -ne 1 ]; do
        echo .
        sleep 5
    done
done

echo "starting nodemanager..."
yarn --daemon start nodemanager
# create foreground process to avoid being killed
echo "a" >> /a.log
tail -f a.log