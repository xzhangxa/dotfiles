#!/bin/bash

set -e

sudo apt update
sudo apt install -y gpg-agent wget

wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
| gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
| sudo tee /etc/apt/sources.list.d/oneAPI.list

sudo apt update

sudo apt install -y intel-oneapi-base-toolkit

sudo usermod -a -G video ${USER}
sudo usermod -a -G render ${USER}
