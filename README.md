# Introduction
hadoop yarn ha
spark 
how those dockerfile builds
how to start up

# TODO
1 优化配置文件自动化过程 docker-compose ssh_config 以及hadoop
2 写readme

# Test
```bash
host$ ./make.sh fetch
host$ ./make.sh build
host$ ./make.sh up
host$ docker exec -it sc /bin/bash
docker$ spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode cluster \
    --driver-memory 1g \
    --executor-memory 1g \
    --executor-cores 1 \
    --queue default  \
    $SPARK_HOME/examples/jars/spark-examples_2.12-3.3.0.jar 10
```
if success, you will see
```bash
2022-08-25 15:31:10,711 INFO yarn.Client: 
         client token: N/A
         diagnostics: N/A
         ApplicationMaster host: rm1
         ApplicationMaster RPC port: 41911
         queue: default
         start time: 1661441461449
         final status: SUCCEEDED
         tracking URL: http://rm2:8088/proxy/application_1661441358874_0001/
         user: root
```