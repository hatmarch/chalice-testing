set -euo pipefail

CODE_SERVER_PORT=${1:-8444}
CODE_SERVER_IMAGE_NAME="${2:-mhildema/chalice-testing-code-server}"

docker build -t $CODE_SERVER_IMAGE_NAME -f ".devcontainer/Dockerfile" ".devcontainer" --target code-server

# SSH needed b/c this is how github connection is made
docker run -it -u vscode:$(getent group docker | awk -F: '{printf $3}') \
   -p 0.0.0.0:${CODE_SERVER_PORT}:8443 \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v $HOME/.aws:/home/vscode/.aws -v $HOME/.gitconfig:/home/vscode/.gitconfig \
   -v $HOME/.ssh:/home/vscode/.ssh \
   -v $HOME/code-server-certs:/home/vscode/code-server-certs -v ${PWD}:/project -e REPO_HOME=/project -e PASSWORD=password \
   $CODE_SERVER_IMAGE_NAME
   