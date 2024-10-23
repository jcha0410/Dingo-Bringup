FROM --platform=arm64 ubuntu:20.04

RUN apt-get update \
    && apt-get install --download-only -y \
    socat \
    && cp /var/cache/apt/archives/socat*.deb /socat.deb
