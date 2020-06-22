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

  GIT_SHA=$(_k8s/scripts/git_sha.sh)

  # Trigger rolling update
  cd _k8s/$@
  kubectl -n $@ wait --for=condition=complete job/pratiba-migrations
  kubectl -n $@ delete job pratiba-migrations
  kustomize edit set image gcr.io/pratiba/pratiba:${GIT_SHA}
  kustomize build | kubectl apply -f -
  kubectl -n $@ wait --for=condition=complete job/pratiba-migrations
  kubectl -n $@ rollout status deployment/pratiba

  echo "[✔️] Deployment complete!"
else
  echo "Environment is missing (staging or production), e.g. ENVIRONMENT=staging";
fi
