#!/bin/bash

# Script to check latest version of Monero and update the version in the Dockerfile

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <repository_path>"
  exit 1
fi

REPOSITORY_PATH=$1

# Check if the directory exists
if [ ! -d "$REPOSITORY_PATH" ]; then
  echo "Directory not found: $REPOSITORY_PATH"
  exit 1
fi

cd "$DIRECTORY_PATH" || { echo "Failed to change directory to: $DIRECTORY_PATH"; exit 1; }

API=$( wget --quiet -O- https://api.github.com/repos/monero-project/monero/tags | jq -r '.[0].name')

NEWEST="${API#v}"
CURRENT=$(grep 'MONERO_VERSION' .github/workflows/docker-image.yml | awk -F': ' '{print $2}')

if [[ ! "$NEWEST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "NEWEST: $NEWEST is not a valid version"
  exit 1
fi
if [[ ! "$CURRENT" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "CURRENT: $CURRENT is not a valid version"
  exit 1
fi

if [ "$NEWEST" != "$CURRENT" ]; then
  find . -type d \( -path ./git -o -path ./data \) -prune -o -type f -exec sed -i "s/${CURRENT}/${NEWEST}/g" {} + && \
  git add -A && git commit -m "🚀 version bump ${CURRENT} --> ${NEWEST}" && git push && \
  echo "$(date +"%Y-%m-%d %H:%M:%S") 🚀 Version Update: $CURRENT --> $NEWEST"
fi