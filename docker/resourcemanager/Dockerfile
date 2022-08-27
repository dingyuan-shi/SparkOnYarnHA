FROM env/hadoop
LABEL author="Dingyuan Shi" 

EXPOSE 8030 8031 8032 8088

COPY ./run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
