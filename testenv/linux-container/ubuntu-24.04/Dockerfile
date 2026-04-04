FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    cron \
    curl \
    git \
    sudo \
    tmux \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash dotfiles \
  && printf 'dotfiles ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/dotfiles \
  && chmod 0440 /etc/sudoers.d/dotfiles

USER dotfiles
WORKDIR /work/dotfiles
