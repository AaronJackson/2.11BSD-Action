FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y expect curl libpcap-dev net-tools git \
    build-essential netcat ftp

RUN git clone https://github.com/simh/simh.git && \
    cd simh && \
    make pdp11 && cp BIN/pdp11 /pdp11

RUN curl -so ci.dsk.gz https://asjackson.s3.fr-par.scw.cloud/211bsd/ci.dsk.gz

COPY runpdp.sh /runpdp.sh

ENTRYPOINT ["/runpdp.sh"]
