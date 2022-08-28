FROM env/spark
LABEL author="Dingyuan Shi" 

# install python and pyspark
RUN yum -y install python36 && pip3 install pyspark -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY ./run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]