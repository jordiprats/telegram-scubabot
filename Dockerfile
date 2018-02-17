FROM ubuntu:16.04
MAINTAINER Jordi Prats
ENV HOME /root

RUN apt-get update
RUN apt-get install python python-pip -y
RUN apt-get install chromium-browser -y
RUN apt-get install wget unzip -y

RUN pip install --upgrade pip
RUN pip install selenium

RUN mkdir -p /usr/local/src
RUN wget https://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip -O /usr/local/src/chromedriver_linux64.zip
RUN unzip /usr/local/src/chromedriver_linux64.zip -d /usr/local/bin

RUN apt-get install xvfb -y
