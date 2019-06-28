#!/bin/bash

echo "Preparing build"

if [[ -n "${PGP_KEY}" ]]; then
 echo Adding pgp key
 TMPFILE=$(mktemp)
 echo >${TMPFILE} "${PGP_KEY}"
 if [[ -n ${PGP_PASS} ]]; then
     echo ${PGP_PASS} | gpg --batch --import --yes --passphrase-fd 0 ${TMPFILE}
 else
     gpg --batch --import ${TMPFILE}
 fi
fi
if [[ -n "${NPM_USER}" ]]; then
    NPMPARAMS="-u ${NPM_USER} -p ${NPM_PASS} -e ${NPM_EMAIL}"
    if [[ -n "${NPM_REGISTRY}" ]]; then NPMPARAMS="${NPMPARAMS} -r ${NPM_REGISTRY}"; fi
    if [[ -n "${NPM_SCOPE}" ]]; then NPMPARAMS="${NPMPARAMS} -s ${NPM_SCOPE}"; fi
    npm-login-noninteractive ${NPMPARAMS}
fi

