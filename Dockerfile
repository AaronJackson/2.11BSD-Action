FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y simh expect curl libpcap-dev net-tools git build-essential

RUN curl -so ci.dsk https://asjackson.s3.fr-par.scw.cloud/211bsd/ci.dsk

COPY runpdp.sh /runpdp.sh
RUN chmod +x /runpdp.sh

RUN git clone https://github.com/simh/simh.git && \
    cd simh && make pdp11 && cp BIN/pdp11 ./pdp11



