FROM ubuntu:jammy
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

ARG TARGETPLATFORM
ARG WARP_VERSION
ARG GOST_VERSION

RUN set -ex && \
    case ${TARGETPLATFORM} in \
        "linux/amd64")   export ARCH="amd64" ;; \
        "linux/arm64")   export ARCH="armv8" ;; \
        *) echo "Unsupported TARGETPLATFORM: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    apt-get update && \
    apt-get install -y curl gpg && \
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ jammy main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get install -y cloudflare-warp=$WARP_VERSION && \
    apt-get clean && \
    apt-get autoremove -y && \
    curl -sL -o /tmp/gost.gz "https://github.com/ginuerzh/gost/releases/download/v${GOST_VERSION}/gost-linux-${ARCH}-${GOST_VERSION}.gz" && \
    gunzip /tmp/gost.gz && \
    mv /tmp/gost /usr/bin/gost && \
    chmod +x /usr/bin/gost && \
    rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh

ENV WARP_PROXY_PORT=40000
ENV WARP_SLEEP=2

EXPOSE 1080

VOLUME [ "/var/lib/cloudflare-warp" ]

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 CMD curl -fsS --socks5-hostname 127.0.0.1:1080 "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || exit 1

ENTRYPOINT [ "/entrypoint.sh" ]