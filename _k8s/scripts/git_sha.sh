#!/bin/bash

if [ -z "$GITHUB_SHA" ]
then
  echo $(git rev-parse --short HEAD)
else
  echo $GITHUB_SHA
fi
