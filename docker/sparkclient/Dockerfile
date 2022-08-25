FROM env/hadoop
LABEL author="Dingyuan Shi" 

# install spark
COPY spark-3.3.0-bin-without-hadoop.tgz /
RUN tar zxvf /spark-3.3.0-bin-without-hadoop.tgz -C /usr/local \
    && mv /usr/local/spark-3.3.0-bin-without-hadoop  /usr/local/spark \
    && rm -f /spark-3.3.0-bin-without-hadoop.tgz
ENV SPARK_HOME /usr/local/spark
ENV PATH $SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

# config spark
COPY spark-defaults.conf /usr/local/spark/conf/
COPY spark-env.sh /usr/local/spark/conf/
ENV YARN_CONF_DIR /usr/local/hadoop/etc/hadoop/
RUN chmod -R 600 /usr/local/spark/conf/ && chown -R root /usr/local/spark/conf/ 
COPY ./run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]