# ensure all namenode is ready
OLD_IFS="$IFS"
IFS=" "
namenodes=($NAMENODES)
IFS="$OLD_IFS"
for namenode in ${namenodes[@]}
do
    while [ `ssh $namenode cat /a.log | grep -cE "^a$"` -ne 1 ]; do
        echo .
        sleep 5
    done
done

# create foreground process to avoid being killed
echo "a" >> /a.log
tail -f a.log