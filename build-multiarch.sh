#!/bin/bash
# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

echo "Building external-dns for multiple architectures..."

# Create build directory if it doesn't exist
mkdir -p build

# Build for AMD64 (x86_64)
echo "Building for AMD64..."
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/external-dns-amd64 -ldflags "-X sigs.k8s.io/external-dns/pkg/apis/externaldns.Version=$(git describe --tags --always --dirty --match "v*") -w -s -X sigs.k8s.io/external-dns/pkg/apis/externaldns.GitCommit=$(git rev-parse --short HEAD)" .

# Build for ARM64 (aarch64) - compatible with Mac M1/M2 and AWS Graviton
echo "Building for ARM64..."
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o build/external-dns-arm64 -ldflags "-X sigs.k8s.io/external-dns/pkg/apis/externaldns.Version=$(git describe --tags --always --dirty --match "v*") -w -s -X sigs.k8s.io/external-dns/pkg/apis/externaldns.GitCommit=$(git rev-parse --short HEAD)" .

# Build for ARM/v7 (32-bit)
echo "Building for ARM/v7..."
CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=7 go build -o build/external-dns-armv7 -ldflags "-X sigs.k8s.io/external-dns/pkg/apis/externaldns.Version=$(git describe --tags --always --dirty --match "v*") -w -s -X sigs.k8s.io/external-dns/pkg/apis/externaldns.GitCommit=$(git rev-parse --short HEAD)" .

echo "Builds completed successfully!"
echo ""
echo "Built binaries:"
ls -lh build/external-dns-*
