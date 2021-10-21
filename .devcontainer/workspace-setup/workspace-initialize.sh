#!/bin/bash

set -euo pipefail

CREDENTIAL_TYPE=${1}
WORKSPACE_FOLDER=${2}
CONTAINER_FOLDER=${3-:${REPO_HOME:-}}

if [[ ${CREDENTIAL_TYPE} != "Canva" ]]; then
    echo "Using non-Canva credential type"
    exit 0
fi

declare CREDENTIALS_FILE_FOLDER=$WORKSPACE_FOLDER/aws-config
declare CREDENTIALS_FILE_PATH=$CREDENTIALS_FILE_FOLDER/credentials

declare CREDENTIALS_FILE_FOLDER_CONTAINER=$CONTAINER_FOLDER/aws-config

mkdir -p ${CREDENTIALS_FILE_FOLDER} || true
rm $CREDENTIALS_FILE_PATH || true
cp ~/.aws/credentials $CREDENTIALS_FILE_PATH

# find all the credential_process line commands, run them, and replace them with cat'ing their output (in container folderspace)
n=1
cat $CREDENTIALS_FILE_PATH | grep -i credential_process | sed -r 's/credential_process *= *//' | while read -r line; do
    echo "Processing line $line"
    # replace that line in the credentials file with the output
    $($line > ${CREDENTIALS_FILE_FOLDER}/cred$n)
    sed -i -r "s#${line}#cat ${CREDENTIALS_FILE_FOLDER_CONTAINER}/cred${n}#" $CREDENTIALS_FILE_PATH
    n=$((n+1))
done
