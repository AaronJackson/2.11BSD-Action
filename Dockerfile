FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y && \
    apt install -y expect curl net-tools git netcat ftp simh

RUN curl -so ci.dsk.gz https://asjackson.s3.fr-par.scw.cloud/211bsd/ci.dsk.gz

# using fuse within docker/podman requires
#    --device /dev/fuse --cap-add SYS_ADMIN
RUN git clone https://github.com/jaylogue/retro-fuse.git && \
    apt install -y libfuse-dev build-essential && \
    cd retro-fuse && make

COPY runpdp.sh /runpdp.sh

ENTRYPOINT ["/runpdp.sh"]
