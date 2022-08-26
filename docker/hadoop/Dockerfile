FROM env/base
LABEL author="Dingyuan Shi"

# install hadoop
RUN  curl https://mirrors.aliyun.com/apache/hadoop/common/hadoop-3.2.3/hadoop-3.2.3.tar.gz -o /hadoop-3.2.3.tar.gz \ 
        && tar -zxf /hadoop-3.2.3.tar.gz -C /usr/local/  \
        && mv /usr/local/hadoop-3.2.3 /usr/local/hadoop  \ 
        && rm /hadoop-3.2.3.tar.gz  \
        && rm -rf /usr/local/hadoop/share/doc \
        && rm -rf /usr/local/hadoop/share/hadoop/*/sources  
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $HADOOP_HOME/bin:$PATH

# config hadoop
COPY *.xml /usr/local/hadoop/etc/hadoop/
RUN chmod -R 600 /usr/local/hadoop/etc/hadoop/  \
    && chown -R root /usr/local/hadoop/etc/hadoop/  \
    && mkdir /usr/local/hadoop/data  \
    && mkdir /usr/local/hadoop/logs  \ 
    && echo "export JAVA_HOME=/usr/local/jdk8" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh 
ENV USER=root \ 
    HDFS_NAMENODE_USER=root \
    HDFS_DATANODE_USER=root \
    HDFS_JOURNALNODE_USER=root \
    HDFS_SECONDARYNAMENODE_USER=root \ 
    YARN_RESOURCEMANAGER_USER=root \
    YARN_NODEMANAGER_USER=root \ 
    HDFS_ZKFC_USER=root