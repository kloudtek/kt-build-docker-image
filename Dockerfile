FROM ubuntu:18.04

ENV TZONE=America/Los_Angeles
ENV LANG=C.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL=C.UTF-8

COPY setup.sh /sbin/setup-image
COPY prepare-build.sh /usr/bin/prepare-build
RUN bash /sbin/setup-image
