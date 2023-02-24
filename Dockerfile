# Partial based on https://github.com/lucaderi/ntopng-docker/blob/master/Dockerfile
# https://packages.ntop.org/apt/

FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Brussels
ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y lsb-release software-properties-common wget && \
    add-apt-repository universe && \
    wget https://packages.ntop.org/apt/20.04/all/apt-ntop.deb && \
    apt install -y ./apt-ntop.deb && \
    apt install -y ntopng ntopng-data redis-server libmysqlclient-dev libpcap0.8
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 3000

RUN echo '#!/bin/bash\n/etc/init.d/redis-server start\nntopng "$@"' > /tmp/run.sh
RUN chmod +x /tmp/run.sh

ENTRYPOINT ["/tmp/run.sh"]
