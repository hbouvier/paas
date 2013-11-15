FROM ubuntu
ENV JDK jdk1.7.0_40
ENV JAVA_HOME /usr/lib/jvm/$JDK
ENV PATH $JAVA_HOME/bin:$PATH

# Base packages
RUN apt-get install -y python-software-properties
RUN add-apt-repository -y ppa:natecarlson/maven3
RUN apt-get update -y
RUN apt-get install -y vim git-core build-essential libssl-dev curl wget maven3
RUN ln -s /usr/bin/mvn3 /usr/bin/mvn

# Install Node.js and npm
RUN git clone https://github.com/creationix/nvm.git /.nvm
RUN echo ". /.nvm/nvm.sh" >> /etc/bash.bashrc
RUN /bin/bash -c '. /.nvm/nvm.sh && nvm install v0.10.18 && nvm use v0.10.18 && nvm alias default v0.10.18 && ln -s /.nvm/v0.10.18/bin/node /usr/bin/node && ln -s /.nvm/v0.10.18/bin/npm /usr/bin/npm'

# Install our PAAS BuildStep
ADD data/app_container/paas /paas
RUN chmod a+x /paas/build-application

# JDK 1.6
apt-get install -y openjdk-6-jdk

# JDK 1.7
# RUN apt-get install -y python-software-properties
# RUN add-apt-repository -y ppa:webupd8team/java
# RUN apt-get update -y
# RUN apt-get install -y oracle-jdk7-installer
#
#RUN wget -O /tmp/jdk-7u25-linux-x64.tar.gz http://download.oracle.com/otn-pub/java/jdk/7u25-b15/jdk-7u25-linux-x64.tar.gz
#RUN cd /tmp/ && tar -xvf /tmp/jdk-7u25-linux-x64.tar.gz && mkdir -p /usr/lib/jvm && mv ./jdk.1.7.0_25 /usr/lib/jvm/jdk1.7.0

#RUN update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0/bin/java" 1
#RUN update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0/bin/javac" 1
#RUN update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0/bin/javaws" 1

#RUN chmod a+x /usr/bin/java 
#RUN chmod a+x /usr/bin/javac 
#RUN chmod a+x /usr/bin/javaws
#RUN chown -R root:root /usr/lib/jvm/jdk1.7.0

# Install JDK 1.7

RUN mkdir -p /usr/lib/jvm/
RUN tar xvzf /paas/jdk-7u40-linux-x64.gz -C /usr/lib/jvm
RUN echo "export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_40" >> /etc/bash.bashrc
RUN echo 'export PATH=${PATH}:${JAVA_HOME}/bin' >> /etc/bash.bashrc

