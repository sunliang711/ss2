#!/bin/bash
version=${1:-1.8.3}
os=${2:-linux}
arch=${3:-amd64}
echo "Installing golang version: ${version} on ${os}-${arch} in /usr/local"

echo "Download golang..."
curl -fLO https://storage.googleapis.com/golang/go${version}.${os}-${arch}.tar.gz || { echo "Download golang failed!";exit 1; }
echo "Extract golang..."
tar xf go${version}.${os}-${arch}.tar.gz
mv go /usr/local
cd /usr/local/bin
for i in $(ls ../go/bin/*);do
    ln -sf $i .
done
