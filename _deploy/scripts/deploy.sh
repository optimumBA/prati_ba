#!/bin/bash

if [[ $@ = "staging" ]] || [[ $@ = "production" ]]
then
  if [[ $@ = "production" ]]
  then
    while true; do
      read -p "Are you sure you want to deploy to production? [y/N] " answer

      case $answer in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
      esac
    done
  fi

  echo "Deploying to $@..."
  kubectl -n $@ create -f _deploy/pratiba-migrations-$@.yml
  kubectl -n $@ delete secret --ignore-not-found=true aws-ecr-credentials
  export AWS_PASSWORD=$(aws ecr get-login-password --region eu-central-1)
  kubectl -n $@ create secret docker-registry aws-ecr-credentials \
    --docker-server=833583610700.dkr.ecr.eu-central-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password=$AWS_PASSWORD \
    --docker-email=almir@optimum.ba
  kubectl -n $@ apply -f _deploy/pratiba-deployment-$@.yml
  export IMAGE_TAG=$(aws ecr list-images --repository=pratiba --max-items=1 --query='imageIds[0].imageTag' | cut -d \" -f2)
  kubectl -n $@ set image deployments/pratiba pratiba-$@=833583610700.dkr.ecr.eu-central-1.amazonaws.com/pratiba:$IMAGE_TAG
  echo "[✔️] Deployment complete!"
else
  echo "Environment is missing (staging or production), e.g. ENVIRONMENT=staging";
fi
