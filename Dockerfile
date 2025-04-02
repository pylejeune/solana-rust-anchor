# Étape 1: Toutes les dépendances système statiques
FROM --platform=linux/amd64 ubuntu:latest AS base

# Labels pour la documentation et la maintenance
LABEL org.opencontainers.image.title="Solana/Anchor Development Environment"
LABEL org.opencontainers.image.description="Ubuntu-based image with Rust, Solana, Anchor, Node.js and related tools for blockchain development"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.created="2024-05-01T00:00:00Z"
LABEL org.opencontainers.image.authors="Your Name <lejeune.py@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/pylejeune/solana-rust-anchor"
LABEL org.opencontainers.image.source="https://github.com/pylejeune/solana-rust-anchor/blob/main/Dockerfile"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="Alyra"
LABEL org.opencontainers.image.documentation="https://github.com/pylejeune/solana-rust-anchor/blob/main/Readme.md"

# Labels supplémentaires utiles
LABEL maintainer="Lejeune Pierre-Yves <lejeune.py@gmail.com>"
LABEL com.example.release-notes="https://github.com/pylejeune/solana-rust-anchor/releases"
LABEL com.example.component="Development Environment"
LABEL com.example.ubuntu-version="latest"
LABEL com.example.rust-version="stable"
LABEL com.example.solana-version="stable"
LABEL com.example.anchor-version="0.30.1"
LABEL com.example.node-version="lts"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/home/developer/.cargo/bin:/home/developer/.local/share/solana/install/active_release/bin:/home/developer/.avm/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    git curl wget build-essential pkg-config libssl-dev libudev-dev \
    python3 python3-pip sudo cmake && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

# Étape 2: Installations qui changent rarement
FROM base AS dependencies

USER developer
WORKDIR /home/developer

# Rust - séparé en deux étapes pour le cache
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
RUN .cargo/bin/rustup component add rustfmt clippy && \
    .cargo/bin/rustup target add wasm32-unknown-unknown

# NVM et Node - optimisé pour le cache
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

# Étape 3: Outils spécifiques au projet
FROM dependencies AS tools

SHELL ["/bin/bash", "--login", "-c"]
RUN source ~/.nvm/nvm.sh && \
    nvm install --lts && \
    nvm alias default lts/* && \
    npm install -g yarn

# Anchor et Solana - séparés pour le cache
RUN cargo install --git https://github.com/coral-xyz/anchor avm --locked
RUN avm install 0.30.1 && avm use 0.30.1
RUN curl -sSfL https://release.anza.xyz/stable/install | sh
RUN solana config set -u devnet

# Étape finale
FROM tools AS runtime

WORKDIR /app
CMD ["/bin/bash", "--login"]