FROM centos
LABEL author="Dingyuan Shi"

# install preliminaries
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*  \ 
    && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*  \
    && yum makecache  \
    && yum update -y  \  
    && yum install -y openssh-server openssh-clients sudo which  \ 
    && yum clean all

# install java
COPY openlogic-openjdk-8u262-b10-linux-x64.tar.gz  /
RUN tar -zxf /openlogic-openjdk-8u262-b10-linux-x64.tar.gz -C /usr/local/  \ 
        && mv /usr/local/openlogic-openjdk-8u262-b10-linux-64 /usr/local/jdk8   \ 
        && rm -f /usr/local/jdk8/src.zip \
        && rm /openlogic-openjdk-8u262-b10-linux-x64.tar.gz
ENV JAVA_HOME /usr/local/jdk8
ENV PATH $JAVA_HOME/bin:$PATH

# config ssh, key is hardcoded in the image
RUN sed -i 's/UsePAM.*/UsePAM no/g' /etc/ssh/sshd_config  \
    && sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config  \
    && sed -i "s/#PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config  \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config  \
    && echo "root:root" | chpasswd  \
    && echo "root   ALL=(ALL)       ALL" >> /etc/sudoers  \
    && ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \  
    && ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''  \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N ''   \
    && mkdir /var/run/sshd  \ 
    && mkdir /root/.ssh \
    && cp /etc/ssh/*_key /root/.ssh  \
    && cp /etc/ssh/*.pub /root/.ssh  \
    && cat /root/.ssh/ssh_host_ecdsa_key.pub >> /root/.ssh/authorized_keys
COPY ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config \ 
    && chown root /root/.ssh/config

EXPOSE 22

COPY ./entrypoint.sh /
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]