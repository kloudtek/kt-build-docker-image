#!/bin/bash

VER=$1

OBRANCH=$(git branch | grep \* | cut -d ' ' -f2)
git branch release-${VER}
git commit -a -m "release ${VER}"
git tag v${VER}
git checkout ${OBRANCH}
git branch -D release-${VER}
git push --tags -o ci.skip
