FROM env/hadoop
LABEL author="Dingyuan Shi"

EXPOSE 8020 9870 8485
COPY ./run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
