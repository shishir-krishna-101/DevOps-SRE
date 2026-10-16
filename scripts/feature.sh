#!/bin/bash

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: ./scripts/feature-start.sh <feature-name>"
    exit 1
fi

BRANCH_NAME="feature/$FEATURE_NAME"

git checkout -b "$BRANCH_NAME"

echo "Created branch: $BRANCH_NAME"
echo "You are now working on this feature branch."