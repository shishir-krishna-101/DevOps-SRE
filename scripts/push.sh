#!/bin/bash

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check if branch was detected
if [ -z "$CURRENT_BRANCH" ]; then
    echo "Could not determine current branch."
    exit 1
fi

# Prevent pushing directly to main
if [ "$CURRENT_BRANCH" = "main" ]; then
    echo "ERROR: You are on main."
    echo "This script only pushes feature branches."
    exit 1
fi

# Make sure it is a feature branch
if [[ "$CURRENT_BRANCH" != feature/* ]]; then
    echo "ERROR: You are not on a feature branch."
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

echo ""
echo "Current branch: $CURRENT_BRANCH"

# Show current status
echo ""
echo "Checking changes..."
git status

# Ask for confirmation
echo ""
read -p "Do you want to add, commit and push these changes? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Stage changes
echo ""
echo "Adding changes..."
git add .

# Check whether anything was staged
git diff --cached --quiet

if [ $? -eq 0 ]; then
    echo "No changes to commit."
    exit 0
fi

# Get commit message
echo ""
read -p "Enter commit message: " COMMIT_MESSAGE

if [ -z "$COMMIT_MESSAGE" ]; then
    echo "ERROR: Commit message cannot be empty."
    exit 1
fi

# Commit changes
echo ""
echo "Creating commit..."
git commit -m "$COMMIT_MESSAGE"

if [ $? -ne 0 ]; then
    echo "Commit failed."
    exit 1
fi

# Push changes
echo ""
echo "Pushing to GitHub..."
git push -u origin "$CURRENT_BRANCH"

if [ $? -ne 0 ]; then
    echo "Push failed."
    exit 1
fi

echo ""
echo "Successfully pushed to $CURRENT_BRANCH"