#!/bin/bash

set -x

curl -fsSL "https://releases.hashicorp.com/terraform/1.9.3/terraform_1.9.3_linux_amd64.zip" \
    -o /tmp/terraform_linux_amd64.zip && \
    unzip "/tmp/terraform_linux_amd64.zip" -d /usr/bin/ && \
    rm /tmp/terraform_linux_amd64.zip

curl -fsSL "https://releases.hashicorp.com/packer/1.11.1/packer_1.11.1_linux_amd64.zip" \
    -o /tmp/packer_linux_amd64.zip && \
    unzip "/tmp/packer_linux_amd64.zip" -d /usr/bin/ && \
    rm /tmp/packer_linux_amd64.zip

apt-get update
sed 's/#.*//' requirements.apt | xargs apt-get install
apt-get clean all

pip3 install --no-cache-dir -r requirements.txt
rm -fr /root/.cache/pip/

ansible-galaxy collection install -v -r requirements.yml
ansible-galaxy role install -v -r requirements.yml --ignore-errors
