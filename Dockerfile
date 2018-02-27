FROM ubuntu:16.04
MAINTAINER Jordi Prats
ENV HOME /root

RUN apt-get update
RUN apt-get install wget curl -y

RUN mkdir -p /opt/scubabot
COPY scubabot* /opt/scubabot/

VOLUME ["/opt/scubabot"]

CMD [ "/bin/bash", "/opt/scubabot/scubabot.sh" ]
