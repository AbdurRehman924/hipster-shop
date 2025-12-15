#!/bin/bash

# Setup SSH key and push to GitHub repository

REPO_URL="git@github.com:AbdurRehman924/hipster-shop.git"
SSH_KEY="main-key-ssh-rsa.pub"

echo "🔑 Setting up SSH key for GitHub..."

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key '$SSH_KEY' not found in current directory"
    echo "Please ensure the key file is in the project root"
    exit 1
fi

# Add SSH key to ssh-agent
echo "🔐 Adding SSH key to ssh-agent..."
eval "$(ssh-agent -s)"
ssh-add "${SSH_KEY%.*}"  # Remove .pub extension for private key

# Test SSH connection
echo "🧪 Testing SSH connection to GitHub..."
ssh -T git@github.com

echo "📡 Adding remote repository..."
git remote add origin $REPO_URL

echo "🚀 Pushing to GitHub..."
git branch -M main
git push -u origin main

echo "✅ Successfully pushed to GitHub!"
echo "🌐 Repository: https://github.com/AbdurRehman924/hipster-shop"
