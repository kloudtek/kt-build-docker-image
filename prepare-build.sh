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

if [[ -n "${SSH_KEY}" ]]; then
    echo  "Adding SSH key"
    eval $(ssh-agent -s)
    mkdir -p ~/.ssh
    ssh-add <(echo "${SSH_KEY}")
fi

if [[ -n "${SSH_KEY_FILE}" ]]; then
    echo  "Copying key file to user home"
    mkdir -p ~/.ssh/
    cp ${SSH_KEY_FILE} ~/.ssh/id_rsa
    chmod 700 ~/.ssh/id_rsa
fi

if [[ -n "${MAVEN_REPO_ID}" ]]; then
    echo  "Adding maven repository credentials"
    mkdir -p ~/.m2/
    echo >~/.m2/settings.xml "<settings xsi:schemaLocation=\"http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd\" xmlns=\"http://maven.apache.org/SETTINGS/1.1.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
    echo >>~/.m2/settings.xml "<servers>"
    echo >>~/.m2/settings.xml "<server>"
    echo >>~/.m2/settings.xml "<id>${MAVEN_REPO_ID}</id>"
    echo >>~/.m2/settings.xml "<username>${MAVEN_REPO_USER}</username>"
    echo >>~/.m2/settings.xml "<password>${MAVEN_REPO_PASS}</password>"
    echo >>~/.m2/settings.xml "</server>"
    echo >>~/.m2/settings.xml "</servers>"
    echo >>~/.m2/settings.xml "</settings>"
fi

if [[ -n "${GITLAB_CI_TOKEN}" ]]; then
    echo  "Adding gitlab maven repository CI job token"
    mkdir -p ~/.m2/
    echo >~/.m2/settings.xml "<settings xsi:schemaLocation=\"http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd\" xmlns=\"http://maven.apache.org/SETTINGS/1.1.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
    echo >>~/.m2/settings.xml "<servers>"
    echo >>~/.m2/settings.xml "<server>"
    echo >>~/.m2/settings.xml "<id>${GITLAB_CI_TOKEN}</id>"
    echo >>~/.m2/settings.xml "<configuration>"
    echo >>~/.m2/settings.xml "<httpHeaders>"
    echo >>~/.m2/settings.xml "<property>"
    echo >>~/.m2/settings.xml "<name>Job-Token</name>"
    echo >>~/.m2/settings.xml "<value>\${env.CI_JOB_TOKEN}</value>"
    echo >>~/.m2/settings.xml "</property>"
    echo >>~/.m2/settings.xml "</httpHeaders>"
    echo >>~/.m2/settings.xml "</configuration>"
    echo >>~/.m2/settings.xml "</server>"
    echo >>~/.m2/settings.xml "</servers>"
    echo >>~/.m2/settings.xml "</settings>"
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
            npm config set "${scope}:registry" ${registry}
        echo "Added scope ${scope} for npm registry: ${registry}"
        fi
        npm config set "${reg}:_authToken" ${token}
        echo "Added access token for npm registry: ${registry}"
    fi
}

npmLogin "${NPM_USER}" "${NPM_PASS}" "${NPM_EMAIL}" "${NPM_TOKEN}" "${NPM_REGISTRY}" "${NPM_SCOPE}"
npmLogin "${NPM_USER2}" "${NPM_PASS2}" "${NPM_EMAIL2}" "${NPM_TOKEN2}" "${NPM_REGISTRY2}" "${NPM_SCOPE2}"
npmLogin "${NPM_USER3}" "${NPM_PASS3}" "${NPM_EMAIL3}" "${NPM_TOKEN3}" "${NPM_REGISTRY3}" "${NPM_SCOPE3}"
