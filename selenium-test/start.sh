#!/bin/bash

set -e

apt-get update -y && sed 's/#.*//' requirements.apt | xargs apt-get install -y
rm -rf /usr/lib/python3/dist-packages/OpenSSL
pip3 install --no-cache-dir -r requirements.txt && rm -fr /root/.cache/pip/
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
apt-get clean all 
chmod 600 /var/run/docker.sock
docker version
docker run -d -p 4442-4444:4442-4444 --name selenium-hub selenium/hub:4.26.0-20241101
sleep 5
cd src && python3 -B main.py
