#!/bin/bash

set -euo pipefail

CREDENTIAL_TYPE=${1}
WORKSPACE_FOLDER=${2}

rsync -a .devcontainer/workspace-setup/ ${WORKSPACE_FOLDER}/.vscode/ --ignore-existing

if [[ $CREDENTIAL_TYPE == "Burner" ]]; then
    echo "Burner credentials detected"
    echo "Logging into AWS SSO with profile ${SSO_PROFILE}"
    aws sso login --profile ${SSO_PROFILE}
fi

#sudo pip install -r requirements.txt