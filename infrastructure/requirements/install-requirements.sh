#!/bin/bash

set -x

apt-get update
sed 's/#.*//' requirements.apt | xargs apt-get install
apt-get clean all

pip3 install --no-cache-dir -r requirements.txt
rm -fr /root/.cache/pip/

ansible-galaxy collection install -v -r requirements.yml
ansible-galaxy role install -v -r requirements.yml --ignore-errors
