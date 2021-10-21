#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM python:3.9

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Or your actual UID, GID on Linux if not the default 1000
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    # NOTE: Groff and man are for awscli and git help respectively
    && apt-get -y install git less jq procps lsb-release rsync zsh zplug apt-transport-https ca-certificates curl gnupg python3-pip groff man \
    #
    # Install pylint
    && pip --disable-pip-version-check --no-cache-dir install pylint ipykernel docker-compose \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # Install Docker
    && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get -y install docker-ce-cli \
    # Install Terraform
    && apt-get install -y software-properties-common \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get -y install terraform \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# install the AWS cli
RUN curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm awscliv2.zip && rm -rf ./aws

# docker post-installation steps
RUN groupadd docker && usermod -aG docker vscode && usermod -aG root vscode

# tfsec install
ARG TFSEC_VERSION="0.58.4"
ARG TFSEC_SHA256SUM="f96fcf8fd22256192cd9ff7a6c8655c7012ff304c3a5eff332bd9d8ff43ed30b"
ARG TMP_DIR="/tmp"

# IMPORTANT: Two spaces are intentionally added before the tfsec path as it is the format produced
# and expected by coreutils' checksum utilities.
# See: https://www.gnu.org/software/coreutils/manual/coreutils.html#md5sum-invocation
RUN curl -L "https://github.com/tfsec/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64" -o "${TMP_DIR}/tfsec-${TFSEC_VERSION}-linux-amd64" \
    && echo "${TFSEC_SHA256SUM}  ${TMP_DIR}/tfsec-${TFSEC_VERSION}-linux-amd64" > "${TMP_DIR}/tfsec_${TFSEC_VERSION}_SHA256SUM" \
    && sha256sum -c "${TMP_DIR}/tfsec_${TFSEC_VERSION}_SHA256SUM" \
    && mv "${TMP_DIR}/tfsec-${TFSEC_VERSION}-linux-amd64" "/usr/local/bin/tfsec" && chmod +x /usr/local/bin/tfsec

# Install terraform-docs
RUN wget -O - https://github.com/terraform-docs/terraform-docs/releases/download/v0.15.0/terraform-docs-v0.15.0-$(uname)-amd64.tar.gz | tar -xzf - -C /usr/local/bin

# Install tflint
RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Install terragrant
ARG TERRAGRUNT_VERSION="0.35.3"
RUN curl -L -o /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" && chmod +x /usr/local/bin/terragrunt

# Install SAM CLI
ARG SAM_ZIP="aws_sam.zip"
ARG SAM_TEMP="/tmp/aws_sam_install"
RUN curl -L "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o "${SAM_ZIP}" \
    && unzip "${SAM_ZIP}" -d "${SAM_TEMP}" && "${SAM_TEMP}/install" && rm "${SAM_ZIP}" && rm -rf "${SAM_TEMP}"

USER vscode

RUN /usr/local/bin/python3 -m pip install -U pytest chalice --user && \
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

COPY --chown=vscode workspace-setup/zshrc.template /home/vscode/.zshrc

ARG PLUGIN_DIR="/home/vscode/.terraform.d/plugins"
ARG HASHICUPS_ZIP="/tmp/hashicups.zip"

# Install plugin for hashicups demo
RUN mkdir -p ${PLUGIN_DIR}/hashicorp.com/edu/hashicups/0.3.1/linux_amd64 \
    && curl -L https://github.com/hashicorp/terraform-provider-hashicups/releases/download/v0.3.1/terraform-provider-hashicups_0.3.1_linux_amd64.zip -o ${HASHICUPS_ZIP} \
    && unzip ${HASHICUPS_ZIP} -d ${PLUGIN_DIR}/hashicorp.com/edu/hashicups/0.3.1/linux_amd64 \
    && chmod +x ${PLUGIN_DIR}/hashicorp.com/edu/hashicups/0.3.1/linux_amd64/* \
    && rm ${HASHICUPS_ZIP}

# Install the credential helper for accessing code-commit repos by role
RUN git config --global credential.helper '!aws codecommit credential-helper $@' \
    && git config --global credential.UseHttpPath true

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=


