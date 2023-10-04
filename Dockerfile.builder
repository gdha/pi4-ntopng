# Partial based on https://github.com/lucaderi/ntopng-docker/blob/master/Dockerfile
# https://packages.ntop.org/apt/

# to build: docker build - < ./Dockerfile.builder
#
# -- Stage 1 -- #
# Compile the app.
FROM ubuntu:focal as builder
WORKDIR /app
# The build context is set to the directory where the repo is cloned.
# This will copy all files in the repo to /app inside the container.
# https://github.com/ntop/ntopng/blob/dev/doc/README.compilation
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Brussels
ENV LANG C.UTF-8

COPY dbip.tar.gz /tmp

RUN mkdir /root/dat_files; cd /root/dat_files; tar xzvf /tmp/dbip.tar.gz ; gunzip *.gz && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y lsb-release software-properties-common wget && \
    apt-get install -y build-essential git bison flex libxml2-dev libpcap-dev libtool libtool-bin rrdtool librrd-dev autoconf pkg-config automake autogen redis-server wget libsqlite3-dev libhiredis-dev libmaxminddb-dev libcurl4-openssl-dev libpango1.0-dev libcairo2-dev libnetfilter-queue-dev zlib1g-dev libssl-dev libcap-dev libnetfilter-conntrack-dev libreadline-dev libjson-c-dev libldap2-dev rename libsnmp-dev libexpat1-dev libmaxminddb-dev libradcli-dev libjson-c-dev libzmq3-dev && \
    apt-get install -y libmariadb-dev libzmq3-dev && \
    apt-get install -y debhelper fakeroot dpkg-sig apt-utils && \
    add-apt-repository universe && \
    cd /app && \
    git clone https://github.com/ntop/nDPI.git && \
    cd nDPI; ./autogen.sh; ./configure; make; cd .. && \
    git clone https://github.com/ntop/ntopng.git && \
    cd ntopng && \
    grep version package.json | cut -d\" -f4 > ./version && \
    ./autogen.sh && \
    ./configure && \
    make && \
    cd packages/ubuntu ; ./configure ; sed -i "s/dpkg-sig .*/#dpkg-sig/g" Makefile ; make all

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# -- Stage 2 -- #
# Create the final environment with the compiled binaries of stage 1.
ENV TZ=Europe/Brussels
ENV LANG C.UTF-8

FROM  ubuntu:focal

# To disable the installation of optional dependencies for all invocations of apt-get, the configuration file
# at /etc/apt/apt.conf.d/00-docker is created with the following settings
# Ref.: https://octopus.com/blog/using-ubuntu-docker-image
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y lsb-release software-properties-common && \
    add-apt-repository universe && \
    apt install -y redis-server libmariadb-dev libpcap0.8 netstat-nat && \
    apt install -y librrd8 logrotate libcurl4 librdkafka1 ethtool libmaxminddb0 && \
    apt install -y libradcli4 libsnmp35 udev whiptail nmap libbpf0 libnuma1 libzmq5 libnetfilter-queue1

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo "Europe/Brussels" > /etc/timezone && chmod 0644 /etc/timezone

WORKDIR /root/
# Copy the binary from the builder stage and set it as the default command.
COPY --from=builder /app/ntopng/packages/ubuntu/ntopng*.deb ./
COPY --from=builder /app/ntopng/version ./

RUN dpkg -i ./ntopng*.deb

COPY redis.conf /etc/redis/
COPY run.sh /tmp/run.sh

# Set the redis ownership
RUN chmod +x /tmp/run.sh && \
    rm -f ./ntopng*.deb && \
    echo ntopng version: $(cat /root/version)

EXPOSE 3000

ENTRYPOINT ["/tmp/run.sh"]
