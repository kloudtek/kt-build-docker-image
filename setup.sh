#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update

# Update timezone

apt-get install -yq tzdata && true

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# Update locales

apt-get install -yq locales && true

# Install other packages

apt-get install -yq curl openjdk-8-jdk curl nodejs npm git gpg

npm --version

# Install angular cli

npm install -g @angular/cli
