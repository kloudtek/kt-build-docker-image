#!/bin/bash

export PRIVATE_KEY=$(cat pgpkey.txt)

docker build -t kt-build-docker-image ..

docker run --name kt-build-docker-image --rm -e "PGP_KEY=${PRIVATE_KEY}" -e "PGP_PASS=foobar" -i -t kt-build-docker-image bash
