# Container de développement Solana/Anchor

Ce container Docker fournit un environnement complet pour le développement blockchain avec Solana et Anchor, incluant tous les outils nécessaires pré-installés.

## Table des matières

- [🚀 Quickstart](#-quickstart)
- [📦 Contenu du container](#-contenu-du-container)
- [🛠 Utilisation avancée](#-utilisation-avancée)
- [📌 Commandes Utiles](#-commandes-utiles)
- [🔄 Mise à jour](#-mise-à-jour)
- [🏗 Structure du Dockerfile](#-structure-du-dockerfile)
- [🤝 Contribution](#-contribution)

## 🚀 Quickstart

Pour démarrer rapidement

1. **Lancer le container sans construire l'image** (avec votre clé Solana) :
```bash
   docker run -it --rm \
     -v $(pwd):/app \
     -v ~/.config/solana/id.json:/home/developer/.config/solana/id.json \
     pylejeune/solana-dev
   ```

OU

1. **Construire l'image** : ~ 13 min

    ```bash
    docker build -t solana-dev .
    ```

2. **Lancer le container** (avec votre clé Solana) :

   ```bash
   docker run -it --rm \
     -v $(pwd):/app \
     -v ~/.config/solana/id.json:/home/developer/.config/solana/id.json \
     solana-dev
   ```

3. **À l'intérieur du container** :
   - Tous les outils sont disponibles (solana, anchor, rust, etc.)
   - Votre code local est monté dans `/app`
   - Votre clé Solana est disponible à son emplacement par défaut

## 📦 Contenu du container

L'environnement contient :

- **Outils de base** :
  - Git, curl, wget, build-essential
  - Python 3, CMake
  - sudo (configuré pour l'utilisateur `developer`)

- **Stack Rust** :
  - Rust stable + wasm32 target
  - rustfmt, clippy

- **Node.js** :
  - NVM (Node Version Manager)
  - Dernière version LTS de Node.js
  - Yarn global

- **Blockchain** :
  - Solana CLI (via Anza)
  - Anchor (AVM) version 0.30.1

## 🛠 Utilisation avancée

### Utilisateur

Le container utilise l'utilisateur `developer` (UID 1000) avec :

- Accès sudo sans mot de passe
- Home directory à `/home/developer`
- Shell bash configuré avec NVM

## 📌 Commandes Utiles

### Construire l'image

```sh
docker build -t solana-dev .
```

### Lancer un container interactif

```sh
docker run -it --rm solana-dev
```

### Monter un volume pour persister les fichiers locaux

```sh
docker run -it --rm -v $(pwd):/app solana-dev
```

### Exécuter une commande spécifique

```sh
docker run --rm solana-dev cargo --version
```

## 🔄 Mise à jour

Pour mettre à jour les outils à l'intérieur du container :

```bash
# Rust
rustup update

# Node.js
nvm install --lts

# Solana
solana-install update

# Anchor
avm update
```

## 🏗 Structure du Dockerfile

Le Dockerfile est multi-stage pour optimiser le cache :

1. **base** : Dépendances système de base
2. **dependencies** : Rust, NVM, outils fondamentaux
3. **tools** : Node.js, Anchor, Solana CLI
4. **runtime** : Image finale

## 🤝 Contribution

Les PR sont les bienvenues pour :

- Mettre à jour les versions des outils
- Ajouter de nouvelles dépendances utiles
- Améliorer la configuration de l'environnement
