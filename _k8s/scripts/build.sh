#!/bin/bash

echo "Building docker image..."

GIT_SHA=$(_k8s/scripts/git_sha.sh)

docker build -t gcr.io/pratiba/pratiba:$GIT_SHA -t gcr.io/pratiba/pratiba:latest .

echo "[✔️] Image build complete!"
echo "Pushing docker image..."

docker push gcr.io/pratiba/pratiba:$GIT_SHA
docker push gcr.io/pratiba/pratiba:latest

echo "[✔️] Image push complete!"
