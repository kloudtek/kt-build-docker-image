#!/bin/bash

set -e

docker build -t kt-build-docker-image .

docker run --name kt-build-docker-image --rm -i -t kt-build-docker-image bash

docker rmi kt-build-docker-image
