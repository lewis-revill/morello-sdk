FROM debian:latest

# Docker variables
ARG TARGETPLATFORM

# Build the image as root user
USER root

# Set bash as default shell
SHELL ["/bin/bash", "-c"]

# Update packages
RUN DEBIAN_FRONTEND=noninteractive apt -qq -y update && \
    DEBIAN_FRONTEND=noninteractive apt -qq -y --no-install-recommends --no-install-suggests upgrade && \
    DEBIAN_FRONTEND=noninteractive apt -qq -y --no-install-recommends --no-install-suggests install \
    ## Add user package
    gawk wget git-core diffstat unzip texinfo libtinfo5 \
    build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
    pylint3 xterm vim telnet rsync \
    ## Build kernel
    bc bison flex device-tree-compiler \
    ## Extra pkg
    locales tmux screen libncurses5-dev \
    ## For building poky docs
    make xsltproc docbook-utils fop dblatex xmlto \
    ## For building LTP
    pkgconf autoconf automake \
    ## Install kas
    && pip3 install kas

# RUN command for specific target platforms
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ] ; \
     then apt-get install -y gcc-multilib ; \
     fi

# Setup the environment
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

# Copy Morello files and configure the environment
RUN mkdir -p /morello-sdk/
COPY . /morello-sdk/

# Build morello-sdk
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ] ; \
    then \
    cd /morello-sdk/morello && \
    source ./env/morello-sdk && \
    ./scripts/build-all.sh --x86_64 --c-apps --rootfs --install; \
    else \
    cd /morello-sdk/morello && \
    source ./env/morello-sdk && \
    ./scripts/build-all.sh --c-apps --rootfs --install; \
    fi

# Verify the content of /morello
RUN ls -lah /morello/

# Remove morello-sdk
RUN rm -fr /morello-sdk

# Add morello user
RUN useradd -ms /bin/bash morello

WORKDIR /home/morello/workspace
VOLUME [ "/home/morello/workspace" ]

# Run bash to keep the container alive
COPY shell-env.sh /
RUN chmod u+x /shell-env.sh
ENTRYPOINT ["sh","/shell-env.sh"]
