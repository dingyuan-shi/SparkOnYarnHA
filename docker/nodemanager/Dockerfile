FROM env/hadoop
LABEL author="Dingyuan Shi"

EXPOSE 8042

COPY ./run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]