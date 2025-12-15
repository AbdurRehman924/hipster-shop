#!/bin/bash

# Clean git history and reinitialize for DigitalOcean project

echo "🗑️  Removing existing git history..."
rm -rf .git

echo "🔄 Initializing new git repository..."
git init

echo "📝 Creating .gitignore for DigitalOcean project..."
cat > .gitignore << 'EOF'
# Build artifacts
**/target/
**/build/
**/dist/
**/out/

# Dependencies
node_modules/
**/vendor/
**/__pycache__/
*.pyc

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Secrets
*.env
.env.*
secrets/
*.key
*.pem

# Docker
.dockerignore

# Kubernetes
kubeconfig
*.kubeconfig

# DigitalOcean
do-config.yaml
EOF

echo "📋 Adding all files to git..."
git add .

echo "💾 Creating initial commit..."
git commit -m "Initial commit: Online Boutique for DigitalOcean

- 11 microservices (Go, C#, Java, Node.js, Python)
- gRPC communication with Protocol Buffers
- Docker multi-arch support
- Ready for DigitalOcean Kubernetes deployment"

echo "✅ Git reinitialized with clean history!"
echo ""
echo "🚀 Next steps:"
echo "1. Create new GitHub repository"
echo "2. git remote add origin <your-new-repo-url>"
echo "3. git push -u origin main"
