#!/bin/bash

echo "Building docker image..."

docker build -t gcr.io/pratiba/pratiba:latest .
docker push gcr.io/pratiba/pratiba:latest

echo "[✔️] Image build complete!"
