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

if [[ -n "${GIT_USER_NAME}" ]]; then
    git config --global user.email "${GIT_USER}"
    echo "Added git user name"
fi

if [[ -n "${GIT_USER_EMAIL}" ]]; then
    git config --global user.email "${GIT_USER}"
    echo "Added git user email"
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

if [[ -n "${SSH_KNOWN_HOSTS}" ]]; then
    echo  "Adding known hosts"
    mkdir -p ~/.ssh
    echo "${SSH_KNOWN_HOSTS}" > ~/.ssh/known_hosts
fi

if [[ -n "${AWS_KEY_ACCESS}" ]]; then
    echo  "Adding AWS Configuration"
    mkdir -p ~/.aws
    echo "[default]" > ~/.aws/config
    echo "region = us-west-2" >> ~/.aws/config
    echo "output = None" >> ~/.aws/config
    echo "[default]" > ~/.aws/credentials
    echo "aws_access_key_id=${AWS_KEY_ID}" >> ~/.aws/credentials
    echo "aws_secret_access_key=${AWS_KEY_SECRET}" >> ~/.aws/credentials
fi

mvnRepo() {
    if [[ -n "$1" ]]; then
        echo  "Adding maven repository credentials for repo $1"
        echo >>~/.m2/settings.xml "<server>"
        echo >>~/.m2/settings.xml "<id>$1</id>"
        echo >>~/.m2/settings.xml "<username>$2</username>"
        echo >>~/.m2/settings.xml "<password>$3</password>"
        echo >>~/.m2/settings.xml "</server>"
    fi
}

mkdir -p ~/.m2/
echo >~/.m2/settings.xml "<settings xsi:schemaLocation=\"http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd\" xmlns=\"http://maven.apache.org/SETTINGS/1.1.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
echo >>~/.m2/settings.xml "<servers>"

mvnRepo ${MAVEN_REPO_ID} ${MAVEN_REPO_USER} ${MAVEN_REPO_PASS}
mvnRepo ${MAVEN_REPO_ID2} ${MAVEN_REPO_USER2} ${MAVEN_REPO_PASS2}
mvnRepo ${MAVEN_REPO_ID3} ${MAVEN_REPO_USER3} ${MAVEN_REPO_PASS3}
mvnRepo ${MAVEN_REPO_ID4} ${MAVEN_REPO_USER4} ${MAVEN_REPO_PASS4}
mvnRepo ${MAVEN_REPO_ID5} ${MAVEN_REPO_USER5} ${MAVEN_REPO_PASS5}

if [[ "${GITLAB_CI}" == "true" ]]; then
    echo  "Adding gitlab maven repository CI job token"
    echo >>~/.m2/settings.xml "<server>"
    echo >>~/.m2/settings.xml "<id>gitlab-maven</id>"
    echo >>~/.m2/settings.xml "<configuration>"
    echo >>~/.m2/settings.xml "<httpHeaders>"
    echo >>~/.m2/settings.xml "<property>"
    echo >>~/.m2/settings.xml "<name>Job-Token</name>"
    echo >>~/.m2/settings.xml "<value>\${env.CI_JOB_TOKEN}</value>"
    echo >>~/.m2/settings.xml "</property>"
    echo >>~/.m2/settings.xml "</httpHeaders>"
    echo >>~/.m2/settings.xml "</configuration>"
    echo >>~/.m2/settings.xml "</server>"
fi

echo >>~/.m2/settings.xml "</servers>"
echo >>~/.m2/settings.xml "</settings>"

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

if [[ -n "${GL_NPM_TOKEN}" ]]; then
    npmLogin "" "" "" "${GL_NPM_TOKEN}" "https://gitlab.com/api/v4/packages/npm/" "${GL_NPM_SCOPE}"
    echo >>~/.npmrc "//gitlab.com/api/v4/projects/${CI_PROJECT_ID}/packages/npm/:_authToken=${GL_NPM_TOKEN}"
    echo "Added gitlab npm repository"
fi

if [[ -f pom.xml ]]; then
    echo "Maven pom.xml file found"
    export POM_VERSION=$( xmlstarlet sel -N 'p=http://maven.apache.org/POM/4.0.0' -t -v '/p:project/p:version/text()' pom.xml );
    export POM_REL_VERSION=$( echo ${POM_VERSION} | sed 's/-SNAPSHOT$//' );
    [[ "$POM_REL_VERSION" =~ (.*[^0-9])([0-9]+)$ ]] && export POM_NEXT_REL_VERSION="${BASH_REMATCH[1]}$((${BASH_REMATCH[2]} + 1))";
    export POM_NEXT_VERSION="${POM_NEXT_REL_VERSION}-SNAPSHOT"
    echo POM Version: ${POM_VERSION}
    echo POM Release Version: ${POM_REL_VERSION}
    echo POM Next Version: ${POM_NEXT_VERSION}
    echo POM Next Release Version: ${POM_NEXT_REL_VERSION}
fi

export JAVA_HOME=/usr/lib/jvm/java-12-openjdk-amd64
