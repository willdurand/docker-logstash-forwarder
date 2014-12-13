FROM debian:wheezy
MAINTAINER William Durand <william.durand1@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y build-essential curl git

RUN curl -s https://go.googlecode.com/files/go1.2.src.tar.gz | tar -v -C /usr/local -xz
RUN cd /usr/local/go/src && ./make.bash --no-clean 2>&1

ENV PATH /usr/local/go/bin:$PATH

RUN git clone git://github.com/elasticsearch/logstash-forwarder.git /opt/logstash-forwarder
RUN cd /opt/logstash-forwarder && go build

CMD [ "/opt/logstash-forwarder/logstash-forwarder", "-config", "/etc/logstash-forwarder/config.json" ]
