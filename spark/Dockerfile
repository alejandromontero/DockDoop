# Create a Spark deployment
#
# Inspired by https://github.com/sequenceiq/docker-spark (kudos to him)

FROM alejandromontero/hadoop:latest
LABEL maintainer="alejandro.montero@bsc.es"

USER root
WORKDIR .

ARG SPARK_VERSION=spark-2.2.1
ENV SPARK_HOME /opt/spark
ENV SPARK_CONF_DIR /opt/spark/conf
ENV PATH $PATH:$SPARK_HOME/bin

RUN wget -q http://archive.apache.org/dist/spark/${SPARK_VERSION}/${SPARK_VERSION}-bin-without-hadoop.tgz && \
    tar -C /opt/ -xzf ${SPARK_VERSION}-bin-without-hadoop.tgz && \
    mv /opt/${SPARK_VERSION}-bin-without-hadoop /opt/spark && \
    rm -f ${SPARK_VERSION}-bin-without-hadoop.tgz

COPY spark_conf/* $SPARK_CONF_DIR/
COPY bootstrap.sh $SPARK_HOME/
RUN  chown root:root $SPARK_HOME/bootstrap.sh && \
     chmod 700 $SPARK_HOME/bootstrap.sh

ENTRYPOINT ["/opt/spark/bootstrap.sh"]
CMD ["standalone", "shell"]
