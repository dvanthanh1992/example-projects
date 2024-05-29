FROM python:3.11.9

ARG TELEGRAM_TOKEN

ENV TELEGRAM_TOKEN=${TELEGRAM_TOKEN}

RUN apt-get update && apt-get install -y wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb

COPY camera-app /camera-app

WORKDIR /camera-app

COPY --from=requirements requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && rm -fr /root/.cache/pip/

CMD ["python", "main.py"]
