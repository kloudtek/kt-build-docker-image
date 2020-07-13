#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update

# NPM Repo

echo "***************************"
echo "***** ADDING RPM REPO *****"
echo "***************************"

apt-get install -yq curl gnupg
curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

echo "deb https://deb.nodesource.com/node_10.x focal main" | tee /etc/apt/sources.list.d/nodesource.list
echo "deb-src https://deb.nodesource.com/node_10.x focal main" | tee -a /etc/apt/sources.list.d/nodesource.list

# Re-updating

apt-get update

# Update timezone

echo "*****************************"
echo "***** UPDATING TIMEZONE *****"
echo "*****************************"

apt-get install -yq tzdata && true

ln -sf /usr/share/zoneinfo/${TZONE} /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# Update locales

echo "****************************"
echo "***** UPDATING LOCALES *****"
echo "****************************"

apt-get install -yq locales && true

# Install other packages

echo "*******************************"
echo "***** INSTALLING PACKAGES *****"
echo "*******************************"

apt-get install -yq openjdk-13-jdk
apt-get install -yq jekyll git gpg maven nodejs jq xmlstarlet openssh-client rsync

echo "**************************************"
echo "***** VERIFYING PACKAGE VERSIONS *****"
echo "**************************************"

echo "- JDK -"
readlink -f $(which java)
echo "- NPM -"
npm --version

# Install angular cli

echo "******************************"
echo "***** INSTALLING AWS CLI *****"
echo "******************************"

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
aws/install -b /bin
rm -rf aws

echo "**********************************"
echo "***** INSTALLING ANGULAR CLI *****"
echo "**********************************"

npm install -g @angular/cli

echo "**********************************"
echo "***** INSTALLING OTHER BUILD TOOLS *****"
echo "**********************************"

npm install -g @adobe/jsonschema2md

echo "***************************"
echo "***** DELETING SCRIPT *****"
echo "***************************"

rm -f /sbin/setup-image
