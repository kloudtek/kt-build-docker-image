FROM ubuntu:18.04

ENV LANG=C.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL=C.UTF-8

COPY setup.sh /sbin/setup-image
RUN bash /sbin/setup-image
