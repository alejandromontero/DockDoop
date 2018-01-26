# Create a hadoop deployment
#
# Inspired by https://github.com/sequenceiq/hadoop-docker (kudos to him)

FROM ubuntu:16.04
LABEL maintainer="alejandro.montero@bsc.es"

USER root
WORKDIR .

RUN apt-get -qq update 
RUN apt-get -qq install -y openssh-server rsync

ARG JAVA_VERSION=jdk1.8.0_101
ARG HADOOP_VERSION=hadoop-2.9.0
ENV JAVA_HOME /opt/java
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin

# Prepare ssh
RUN  rm /etc/ssh/ssh_host_dsa_key && \
     ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
     rm /etc/ssh/ssh_host_rsa_key && \
     ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
     ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
     cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys


RUN wget -q https://aloja.bsc.es/public/aplic2/tarballs/${JAVA_VERSION}.tar.gz && \
    wget -q http://archive.apache.org/dist/hadoop/core/${HADOOP_VERSION}/${HADOOP_VERSION}.tar.gz && \
    tar -C /opt/ -xzf $JAVA_VERSION.tar.gz && \
    mv /opt/$JAVA_VERSION /opt/java && \
    rm -f  $JAVA_VERSION.tar.gz && \
    tar -C /opt/ -xzf $HADOOP_VERSION.tar.gz && \
    mv /opt/$HADOOP_VERSION /opt/hadoop && \
    rm -f $HADOOP_VERSION.tar.gz

# Prepare HDFS folders
RUN mkdir /dfs && chmod 777 /dfs

COPY hadoop_conf/* $HADOOP_CONF_DIR/
COPY bootstrap.sh /opt/hadoop
COPY hdfs_test.txt /opt/hadoop
COPY  ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && chown root:root /root/.ssh/config
RUN chown root:root $HADOOP_HOME/bootstrap.sh && \
    chmod 700 $HADOOP_HOME/bootstrap.sh

ENTRYPOINT ["/opt/hadoop/bootstrap.sh"]
CMD ["standalone"]

# Hdfs - Mapred - Yarn ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 10020 19888 \
       8030 8031 8032 8033 8040 8042 8088 49707 2122 
