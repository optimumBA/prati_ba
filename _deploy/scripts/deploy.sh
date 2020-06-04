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

  # Start migration
  kubectl -n $@ create -f _deploy/pratiba-migrations-$@.yml

  # Trigger rolling update
  kubectl -n $@ apply -f _deploy/pratiba-deployment-$@.yml
  kubectl -n $@ rollout restart deployment pratiba

  echo "[✔️] Deployment complete!"
else
  echo "Environment is missing (staging or production), e.g. ENVIRONMENT=staging";
fi
