# Partir d'une base Ubuntu
FROM --platform=linux/amd64 ubuntu:latest

# Éviter les interactions pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

# Installer les dépendances de base en une seule couche
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    libudev-dev \
    python3 \
    python3-pip \
    sudo \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Créer un utilisateur non-root
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

USER developer
WORKDIR /home/developer

# Installer Rust via rustup (séparez les commandes pour mieux utiliser le cache)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/developer/.cargo/bin:${PATH}"

# Configurer Rust (séparé pour mieux utiliser le cache)
RUN rustup component add rustfmt clippy
RUN rustup target add wasm32-unknown-unknown

# Installer Node.js via NVM
ENV NVM_DIR /home/developer/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $HOME/.bashrc

# Installer Node.js et yarn (séparé pour mieux utiliser le cache)
SHELL ["/bin/bash", "--login", "-c"]
RUN source $NVM_DIR/nvm.sh && nvm install node
RUN source $NVM_DIR/nvm.sh && nvm use node
RUN source $NVM_DIR/nvm.sh && npm install -g yarn
RUN source $NVM_DIR/nvm.sh && nvm alias default node

# Installer Anchor (séparé en plusieurs étapes pour le cache)
RUN cargo install --git https://github.com/coral-xyz/anchor avm --force
RUN echo 'export PATH="/home/developer/.cargo/bin:$PATH"' >> ~/.bashrc
RUN avm install 0.30.1
RUN avm use 0.30.1

# Installer Solana depuis Anza
RUN sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"
ENV PATH="/home/developer/.local/share/solana/install/active_release/bin:/home/developer/.avm/bin:/home/developer/.cargo/bin:${PATH}"

# Vérifications (séparées pour le cache)
RUN solana --version
RUN anchor --version
RUN rustc --version
RUN yarn --version

# Configurer le répertoire de travail
WORKDIR /app

# Point d'entrée
CMD ["/bin/bash", "--login"]