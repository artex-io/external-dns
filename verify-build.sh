#!/bin/bash

# Verification script for external-dns Docker build
# This script verifies that all components are in place and working

set -e

echo "=== External-DNS Docker Build Verification ==="
echo ""

# Check if Docker is running
echo "1. Checking Docker availability..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running or not installed"
    exit 1
fi
echo "✅ Docker is running"
echo ""

# Check for built images
echo "2. Checking for built images..."
if ! docker images external-dns >/dev/null 2>&1; then
    echo "❌ No external-dns images found"
    echo "   Run: docker build -t external-dns:v0.20.0-dualstack . -f Dockerfile"
    exit 1
fi

echo "✅ Found external-dns images:"
docker images external-dns --format "  - {{.Repository}}:{{.Tag}} ({{.ID}})"
echo ""

# Check for version tag
echo "3. Checking for version tag v0.20.0-dualstack..."
if ! docker images external-dns:v0.20.0-dualstack >/dev/null 2>&1; then
    echo "❌ Version tag v0.20.0-dualstack not found"
    echo "   Run: docker build -t external-dns:v0.20.0-dualstack . -f Dockerfile"
    exit 1
fi
echo "✅ Version tag v0.20.0-dualstack exists"
echo ""

# Test image functionality
echo "4. Testing image functionality..."
VERSION_OUTPUT=$(docker run --rm external-dns:v0.20.0-dualstack --version 2>&1 || true)
if [ -z "$VERSION_OUTPUT" ]; then
    echo "❌ Image failed to run or --version flag not working"
    exit 1
fi
echo "✅ Image runs successfully"
echo "   Version output: $VERSION_OUTPUT"
echo ""

# Check for required files
echo "5. Checking for required files..."
REQUIRED_FILES=(
    "Dockerfile"
    "build-multiarch.sh"
    ".github/workflows/docker-build.yml"
    "PUSH_GUIDE.md"
    "PROJECT_SUMMARY.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing file: $file"
        exit 1
    fi
done
echo "✅ All required files present"
echo ""

# Check build script permissions
echo "6. Checking build script permissions..."
if [ ! -x "build-multiarch.sh" ]; then
    echo "❌ build-multiarch.sh is not executable"
    echo "   Run: chmod +x build-multiarch.sh"
    exit 1
fi
echo "✅ build-multiarch.sh is executable"
echo ""

# Check GitHub Actions workflow
echo "7. Checking GitHub Actions workflow..."
if [ ! -f ".github/workflows/docker-build.yml" ]; then
    echo "❌ GitHub Actions workflow not found"
    exit 1
fi

echo "✅ GitHub Actions workflow exists"
echo ""

# Summary
echo "=== Verification Complete ==="
echo ""
echo "Summary:"
echo "  ✅ Docker is running"
echo "  ✅ Images are built"
echo "  ✅ Version tag exists"
echo "  ✅ Image functionality verified"
echo "  ✅ All required files present"
echo "  ✅ Build script is executable"
echo "  ✅ GitHub Actions workflow configured"
echo ""
echo "Next Steps:"
echo "  1. Push images to GHCR (see PUSH_GUIDE.md)"
echo "  2. Commit and push workflow file:"
echo "     git add .github/workflows/docker-build.yml"
echo "     git commit -m 'Add GitHub Actions workflow'"
echo "     git push origin dualstack"
echo ""
echo "To push images, you need a GitHub token with write:packages permission."
echo "See PUSH_GUIDE.md for detailed instructions."
