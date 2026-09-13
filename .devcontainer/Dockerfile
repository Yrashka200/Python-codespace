# ~150 MB base instead of 1.5 GB
FROM python:3.12-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1

# Minimum system packages (only what's needed for C-extensions)
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        ca-certificates \
        zsh \
        make \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# uv — Rust-based package manager (10-100× faster than Poetry)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Ruff via pip (single binary instead of black+flake8+isort)
RUN pip install --no-cache-dir ruff==0.7.4

# Non-root user
ARG USERNAME=vscode
RUN useradd -m -s /bin/zsh $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /workspaces

# Lightweight zsh config instead of Oh My Zsh
RUN echo 'autoload -U compinit && compinit' > ~/.zshrc \
    && echo 'setopt hist_ignore_all_dups share_history' >> ~/.zshrc \
    && echo 'PROMPT="%F{cyan}%~%f %F{green}❯%f "' >> ~/.zshrc \
    && echo 'alias ll="ls -lah"' >> ~/.zshrc \
    && echo 'alias gs="git status -sb"' >> ~/.zshrc \
    && echo 'alias gl="git log --oneline --graph -15"' >> ~/.zshrc \
    && echo 'alias uvx="uv run"' >> ~/.zshrc

# Git defaults
RUN git config --global core.autocrlf input \
    && git config --global init.defaultBranch main \
    && git config --global pull.rebase false