FROM golang:1.21 AS build-hugo

# https://github.com/AarynSmith/vscode-dev-container-hugo/blob/master/.devcontainer/Dockerfile
# VARIANT can be either 'hugo' for the standard version or 'hugo_extended' for the extended version.
ARG VARIANT=hugo_extended
# VERSION can be either 'latest' or a specific version number
ARG VERSION=0.119.0

RUN apt-get update && apt-get install -y ca-certificates openssl git curl && \
    rm -rf /var/lib/apt/lists/* && \
    case ${VERSION} in \
    latest) \
    export VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}') ;;\
    esac && \
    echo ${VERSION} && \
    wget -O ${VERSION}.tar.gz https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${VARIANT}_${VERSION}_Linux-64bit.tar.gz && \
    tar xf ${VERSION}.tar.gz && \
    mv hugo* /usr/bin/hugo && \
    go install github.com/yaegashi/muslstack@latest && \
    muslstack -s 0x800000 /usr/bin/hugo

FROM ubuntu:22.04 as devcontainer

RUN apt-get update && \
    apt-get update \
    && apt-get install -y \
    tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo 'Asia/Tokyo' >/etc/timezone \
    && apt-get -y upgrade \
    git \
    imagemagick \
    bash-completion \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

USER $USERNAME

COPY --from=build-hugo /usr/bin/hugo /usr/bin/hugo
