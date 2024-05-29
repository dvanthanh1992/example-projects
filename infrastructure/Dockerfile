FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PACKER_LATEST_VERSION=1.10.0

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common; \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -; \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"; \
    apt-cache policy docker-ce; \
    apt-get install -y docker-ce

COPY --from=requirements requirements.apt .
RUN apt-get update && \
    sed 's/#.*//' requirements.apt | xargs apt-get install -y && \
    apt-get clean all

RUN curl -fsSL "https://releases.hashicorp.com/packer/${PACKER_LATEST_VERSION}/packer_${PACKER_LATEST_VERSION}_linux_amd64.zip" \
    -o /tmp/packer_linux_amd64.zip && \
    unzip "/tmp/packer_linux_amd64.zip" -d /usr/bin/ && \
    rm /tmp/packer_linux_amd64.zip

COPY --from=requirements requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt && \
    rm -fr /root/.cache/pip/

COPY --from=requirements requirements.yml .
RUN ansible-galaxy collection install -v -r requirements.yml && \
    ansible-galaxy role install -v -r requirements.yml --ignore-errors