FROM docker.io/squidfunk/mkdocs-material:9.7

WORKDIR /docs
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
