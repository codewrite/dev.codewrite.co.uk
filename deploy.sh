#!/bin/bash
# Deployment script for local builds

echo "Building Hugo site..."
hugo --minify

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Site built to: docs/"
    echo ""
    echo "To deploy:"
    echo "  git add docs/"
    echo "  git commit -m 'Deploy site'"
    echo "  git push"
else
    echo "Build failed!"
    exit 1
fi
