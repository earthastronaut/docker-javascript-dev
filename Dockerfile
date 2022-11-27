# ############################################################################ #
# Application
# ############################################################################ #

FROM node AS app

# ---------------------------------------------------------------------------- #
# System Configuration
# ---------------------------------------------------------------------------- #

ARG APPDIR=/home/node/app

ENV USER=node \
    HOME=/home/node

ENV PORT=8000 \
    NPM_CONFIG_LOGLEVEL=info \
    APPDIR=${APPDIR}

USER ${USER}
WORKDIR ${APPDIR}

# ---------------------------------------------------------------------------- #
# Application Configuration
# ---------------------------------------------------------------------------- #

ARG SERVICE_NAME=landing
ARG VERSION=dev
ENV VERSION=${VERSION} \
    PATH="${APPDIR}/node_modules/.bin:${PATH}"

# ---------------------------------------------------------------------------- #
# Install Application Dependencies
# ---------------------------------------------------------------------------- #

# COPY ["package.json", "package-lock.json*", "./"]
# RUN npm install

# ---------------------------------------------------------------------------- #
# Source files
# ---------------------------------------------------------------------------- #

# COPY src .

# ---------------------------------------------------------------------------- #
# Command
# ---------------------------------------------------------------------------- #

EXPOSE 8000
CMD [ "npm", "run", "start" ]

# ############################################################################ #
# Dev
# ############################################################################ #

FROM app AS dev

SHELL ["/bin/bash", "-c"]

# ---------------------------------------------------------------------------- #
# Env
# ---------------------------------------------------------------------------- #

ENV NPM_CONFIG_LOGLEVEL=warn \
    CI=true

# ---------------------------------------------------------------------------- #
# dev: git, wget, ...
# ---------------------------------------------------------------------------- #

USER root
RUN echo "Install System Dependencies" \
    # ------------------------------------ #
    # NOTE: This always triggers a re-cache. And the apt-get is needed
    # for steps further below.
    && apt-get -q update \
    && apt-get install -yq --no-install-recommends \
    wget \
    # for github installation using ssh
    openssh-client \
    git \
    # ------------------------------------ #
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    ``
USER ${USER}

# ---------------------------------------------------------------------------- #
# dev: zshrc
# ---------------------------------------------------------------------------- #

# Install zsh
USER root
RUN apt-get -q update && apt-get install -yq --no-install-recommends zsh
USER ${USER}

# Configure ENV for zsh and oh-my-zsh.
ENV SHELL=/usr/bin/zsh \
    ZSH="${HOME}/.oh-my-zsh" \
    ZSH_THEME="kolo" \
    ZSH_PLUGINS="git,git-flow,jsontools" 

# Install oh-my-zsh.
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ${ZSH}
# checkout specific version
# RUN git --git-dir=${ZSH}/.git checkout -q 7dcabbe6826073ef6069c8a4b6f9a943f00d2df0 \
#     && [[ $(md5sum ${ZSH}/oh-my-zsh.sh) == "5941b93de29c5459babd5ac81473d6f1  ${ZSH}/oh-my-zsh.sh" ]]

# Copy over startup file.
COPY config/zshrc ${HOME}/.zshrc

# ---------------------------------------------------------------------------- #
# dev: vscode
# ---------------------------------------------------------------------------- #

# Avoid extension reinstalls
# https://code.visualstudio.com/remote/advancedcontainers/avoid-extension-reinstalls
RUN mkdir -p ${HOME}/.vscode-server/extensions \
    && mkdir -p ${HOME}/.vscode-server-insiders/extensions \
    ``
