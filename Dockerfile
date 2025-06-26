# syntax=docker/dockerfile:1

FROM ubuntu:22.04

# This ARG is set automatically by Buildx during multi-arch builds
ARG TARGETARCH

# Example: download binary for the correct architecture
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      curl -L -o /usr/local/bin/myapp https://example.com/downloads/myapp-linux-amd64 ; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      curl -L -o /usr/local/bin/myapp https://example.com/downloads/myapp-linux-arm64 ; \
    fi && \
    chmod +x /usr/local/bin/myapp
    
ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_$TARGETARCH

FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_$TARGETARCH}
EXPOSE 6969
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="6969/tcp,6969/udp"

RUN apk add --no-cache libintl sqlite-libs icu-libs

ARG VERSION
ARG SBRANCH
ARG PACKAGE_VERSION=${VERSION}
RUN mkdir "${APP_DIR}/bin" && \
    curl -fsSL "https://whisparr.servarr.com/v1/update/${SBRANCH}/updatefile?version=${VERSION}&os=linuxmusl&runtime=netcore&arch=x64" | tar xzf - -C "${APP_DIR}/bin" --strip-components=1 && \
    rm -rf "${APP_DIR}/bin/Whisparr.Update" && \
    echo -e "PackageVersion=${PACKAGE_VERSION}\nPackageAuthor=[hotio](https://github.com/hotio)\nUpdateMethod=Docker\nBranch=${SBRANCH}" > "${APP_DIR}/package_info" && \
    chmod -R u=rwX,go=rX "${APP_DIR}"

COPY root/ /
