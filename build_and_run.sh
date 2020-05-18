#!/bin/bash
set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")"

export DOCKER_BUILDKIT=1
docker build --progress=plain --tag tensorrt7-crash-reproducer .
docker run -it --rm --gpus all tensorrt7-crash-reproducer
