#!/bin/bash

echo "Preparing build"

if [[ -n "${PGP_KEY}" ]]; then
 TMPFILE=$(mktemp)
 echo >${TMPFILE} "${PGP_KEY}"
 if [[ -n ${PGP_PASS} ]]; then
     echo ${PGP_PASS} | gpg --batch --import --yes --passphrase-fd 0 ${TMPFILE}
 else
     gpg --batch --import ${TMPFILE}
 fi
 echo "Added GPG key"
fi

npmLogin() {
    local user=$1
    local pw=$2
    local email=$3
    local token=$4
    local registry=$5
    local scope=$6
    if [[ -n "${user}" ]]; then
        local token=$(curl -s -H "Accept: application/json" -H "Content-Type:application/json" -X PUT --data "{\"name\": \"${user}\", \"password\": \"${pw}\"}" ${registry}-/user/org.couchdb.user:${user} 2>&1 | jq -r .token )
        echo "Retrieved access token for npm registry: ${registry}"
    fi
    if [[ -n "${token}" ]]; then
        local reg=$(echo "${registry}" | sed "s/^http://" | sed "s/^https://")
        if [[ -n "${scope}" ]]; then
            echo >>~/.npmrc "${scope}:registry=${registry}"
        echo "Added scope ${scope} for npm registry: ${registry}"
        fi
        echo >>~/.npmrc "${reg}/:_authToken=${registry}"
        echo "Added access token for npm registry: ${registry}"
    fi
}

npmLogin "${NPM_USER}" "${NPM_PASS}" "${NPM_EMAIL}" "${NPM_TOKEN}" "${NPM_REGISTRY}" "${NPM_SCOPE}"
npmLogin "${NPM_USER2}" "${NPM_PASS2}" "${NPM_EMAIL2}" "${NPM_TOKEN2}" "${NPM_REGISTRY2}" "${NPM_SCOPE2}"
npmLogin "${NPM_USER3}" "${NPM_PASS3}" "${NPM_EMAIL3}" "${NPM_TOKEN3}" "${NPM_REGISTRY3}" "${NPM_SCOPE3}"
