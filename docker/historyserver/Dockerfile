FROM env/spark
LABEL author="Dingyuan Shi"

EXPOSE 18080 10020 19888

COPY ./run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
