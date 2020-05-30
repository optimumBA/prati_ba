#!/bin/bash

echo "Building docker image..."

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 833583610700.dkr.ecr.eu-central-1.amazonaws.com
docker build -t 833583610700.dkr.ecr.eu-central-1.amazonaws.com/pratiba:latest .
docker push 833583610700.dkr.ecr.eu-central-1.amazonaws.com/pratiba:latest

echo "[✔️] Image build complete!"
