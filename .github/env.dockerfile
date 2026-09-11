FROM python:3.13-alpine

LABEL org.opencontainers.image.description="Pandoc runtime with bibtexparser."
LABEL org.opencontainers.image.licenses="CC0-1.0"
LABEL org.opencontainers.image.arch="linux/amd64"

RUN apk add --no-cache \
    wget \
    tar \
    make \
    gcompat \
    texlive \
    texlive-xetex \
    texlive-latexextra \
    nodejs \
    npm \
    git \
    font-liberation \
    github-cli

RUN npm install -g awesome-lint
RUN pip install --no-cache-dir zensical bibtexparser
RUN wget https://github.com/jgm/pandoc/releases/download/3.10/pandoc-3.10-linux-amd64.tar.gz  \
    && tar -xzf pandoc-3.10-linux-amd64.tar.gz --strip-components=1 -C /usr/local/  \
    && rm pandoc-3.10-linux-amd64.tar.gz
