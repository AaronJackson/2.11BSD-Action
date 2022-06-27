FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y expect curl net-tools git netcat ftp simh

RUN curl -so ci.dsk.gz https://asjackson.s3.fr-par.scw.cloud/211bsd/ci.dsk.gz

COPY runpdp.sh /runpdp.sh

ENTRYPOINT ["/runpdp.sh"]
