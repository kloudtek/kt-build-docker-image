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
    NPM_TOKEN=$(curl -s -H "Accept: application/json" -H "Content-Type:application/json" -X PUT --data "{\"name\": \"${NPM_USER}\", \"password\": \"${NPM_PASS}\"}" ${NPM_REGISTRY}-/user/org.couchdb.user:${NPM_USER} 2>&1 | jq -r .token )
    if [[ -n "${NPM_SCOPE}" ]]; then
        REG=$(echo "${NPM_REGISTRY}" | sed "s/^http:/:/" | sed "s/^https://")
        echo >>~/.npmrc "${NPM_SCOPE}:registry=${NPM_REGISTRY}";
    fi
    echo >>~/.npmrc "${REG}:_authToken=${NPM_TOKEN}"
fi

