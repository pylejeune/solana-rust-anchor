# Partir d'une base Ubuntu
FROM --platform=linux/amd64 ubuntu:latest

# Éviter les interactions pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

# Installer les dépendances de base
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

# Installer Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/developer/.cargo/bin:${PATH}"

# Configurer Rust
RUN rustup component add rustfmt clippy && \
    rustup target add wasm32-unknown-unknown

# Installer Node.js via NVM
ENV NVM_DIR /home/developer/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $HOME/.bashrc

# Installer la dernière version de Node.js et yarn
SHELL ["/bin/bash", "--login", "-c"]
RUN source $NVM_DIR/nvm.sh && \
    nvm install node && \
    nvm use node && \
    npm install -g yarn && \
    nvm alias default node



# Installer Anchor directement depuis GitHub avec Cargo
# Au lieu d'utiliser AVM qui peut avoir des problèmes avec certaines versions
##RUN cargo install --git https://github.com/coral-xyz/anchor anchor-cli --locked && \
RUN cargo install --git https://github.com/coral-xyz/anchor avm --force && \
    echo 'export PATH="/home/developer/.cargo/bin:$PATH"' >> ~/.bashrc && \
    avm install 0.30.1 && \
    avm use 0.30.1

# Installer Solana depuis Anza 
RUN sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)" && \
    export PATH="/home/developer/.local/share/solana/install/active_release/bin:$PATH" 


# Mettre à jour le PATH pour la session
ENV PATH="/home/developer/.local/share/solana/install/active_release/bin:/home/developer/.avm/bin:/home/developer/.cargo/bin:${PATH}"

# Vérifier les installations
RUN solana --version && \
    anchor --version && \
    rustc --version && \
    node --version && \
    yarn --version

# Configurer le répertoire de travail
WORKDIR /app

# Point d'entrée
CMD ["/bin/bash", "--login"]