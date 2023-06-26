# Update the NODE_VERSION arg in docker-compose.yml to pick a Node version: 10, 12, 14
ARG NODE_VERSION=14
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:0-${NODE_VERSION}

# VARIANT can be either 'hugo' for the standard version or 'hugo_extended' for the extended version.
ARG VARIANT=hugo_extended
# VERSION can be either 'latest' or a specific version number
ARG VERSION=0.113.0

# Download Hugo
RUN apt-get update && apt-get install -y ca-certificates openssl git curl && \
    rm -rf /var/lib/apt/lists/* && \
    case ${VERSION} in \
    latest) \
    export VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}') ;;\
    esac && \
    echo ${VERSION} && \
    wget -O ${VERSION}.tar.gz https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${VARIANT}_${VERSION}_Linux-64bit.tar.gz && \
    tar xf ${VERSION}.tar.gz && \
    mv hugo /usr/bin/hugo

# Hugo dev server port
EXPOSE 1313

# workaround for "No space left on device"
RUN rm -rf /usr/share/dotnet
RUN rm -rf /opt/ghc
RUN rm -rf "/usr/local/share/boost"
RUN rm -rf "$AGENT_TOOLSDIRECTORY"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get update \
    && apt-get -y install --no-install-recommends `apt-get --assume-no install texlive-full | awk '/The following additional packages will be installed/{f=1;next} /Suggested packages/{f=0} f' | tr ' ' '\n' | grep -vP 'doc$' | grep -vP 'latex-cjk' | tr '\n' ' '`

# [Optional] Uncomment if you want to install more global node packages
# RUN sudo -u node npm install -g <your-package-list-here>
