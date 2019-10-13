FROM ubuntu:18.04

ENV TZONE=America/Los_Angeles
ENV LANG=C.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL=C.UTF-8

COPY setup.sh /sbin/setup-image
COPY scripts/prepare-build.sh /usr/bin/prepare-build
COPY scripts/git-init.sh /usr/bin/git-init
COPY scripts/set-gl-sshorigin.sh /usr/bin/set-gl-sshorigin
RUN bash /sbin/setup-image
