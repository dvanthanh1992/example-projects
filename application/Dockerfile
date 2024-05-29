FROM python:3.11.9

ARG TELEGRAM_TOKEN

ENV TELEGRAM_TOKEN=${TELEGRAM_TOKEN}

COPY --from=requirements requirements.apt .
RUN apt-get update && \
    sed 's/#.*//' requirements.apt | xargs apt-get install -y && \
    apt-get clean all

COPY --from=requirements requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && rm -fr /root/.cache/pip/

COPY camera-src /camera-src

WORKDIR /camera-src

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb

CMD ["python", "main.py"]
