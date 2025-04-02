# Dockerfile pour Environnement de Développement Rust/Node.js/Solana/Anchor

Ce dépôt contient un Dockerfile configuré pour créer un environnement de développement complet sur une base Ubuntu. L'image est conçue pour les développeurs souhaitant travailler avec Rust, Node.js, Solana et Anchor, ainsi qu'avec les outils et dépendances de base. L'objectif est de fournir un environnement pré-configuré et reproductible pour faciliter le développement et le déploiement d'applications.

## Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Dépendances installées](#dépendances-installées)
- [Étapes de configuration](#étapes-de-configuration)
- [Utilisation](#utilisation)
- [Personnalisation](#personnalisation)
- [Crédits et licence](#crédits-et-licence)

## Fonctionnalités

- **Base Ubuntu (linux/amd64)** : Utilisation de la dernière version d'Ubuntu pour la stabilité et la compatibilité.
- **Installation automatique des dépendances de base** : Git, curl, wget, outils de compilation, bibliothèques SSL et Udev, Python3 et pip, sudo, cmake, etc.
- **Création d'un utilisateur non-root** : Un utilisateur `developer` est créé pour éviter de travailler en tant que root et améliorer la sécurité.
- **Installation de Rust** : Installation de Rust via `rustup` avec l'ajout des composants `rustfmt` et `clippy`, ainsi que la cible `wasm32-unknown-unknown`.
- **Installation de Node.js et Yarn via NVM** : Utilisation de NVM pour installer la dernière version de Node.js et Yarn.
- **Installation d'Anchor (via AVM)** : Installation d'Anchor directement depuis GitHub en utilisant Cargo pour faciliter le déploiement de projets Solana.
- **Installation de Solana** : Installation de Solana CLI via le script d’Anza pour accéder aux dernières versions stables.
- **Configuration du PATH** : Mise à jour des variables d'environnement pour garantir l'accès aux exécutables installés.
- **Vérification des versions** : Exécution de commandes pour afficher les versions installées de Solana, Anchor, Rust, Node.js et Yarn.

## Dépendances installées

Le Dockerfile installe les packages suivants :

- **Système et compilation** :
  - `build-essential`
  - `pkg-config`
  - `cmake`
- **Gestion des sources et téléchargement** :
  - `git`
  - `curl`
  - `wget`
- **Bibliothèques nécessaires** :
  - `libssl-dev`
  - `libudev-dev`
- **Environnement Python** :
  - `python3`
  - `python3-pip`
- **Utilitaires** :
  - `sudo`

## Étapes de configuration

1. **Base et mise à jour**  
   Le Dockerfile part d'une image Ubuntu (`FROM --platform=linux/amd64 ubuntu:latest`).  
   La variable d'environnement `DEBIAN_FRONTEND=noninteractive` est utilisée pour éviter toute interaction lors de l'installation des paquets.

2. **Installation des dépendances de base**  
   Mise à jour des paquets avec `apt-get update` et installation de divers outils nécessaires pour le développement. Les listes de paquets sont ensuite nettoyées pour réduire la taille de l'image.

3. **Création d'un utilisateur non-root**  
   Création de l'utilisateur `developer` avec son répertoire personnel et ajout de droits sudo sans mot de passe pour faciliter les installations ultérieures.

4. **Installation de Rust**  
   Installation de Rust via `rustup` est réalisée avec un script fourni par la communauté.  
   Les composants supplémentaires `rustfmt` et `clippy` sont installés pour aider à la mise en forme du code et aux vérifications statiques.  
   La cible `wasm32-unknown-unknown` est ajoutée pour permettre la compilation vers WebAssembly.

5. **Installation de Node.js via NVM**  
   Le script d'installation de NVM est exécuté pour gérer les versions de Node.js.  
   Ensuite, la dernière version stable de Node.js est installée et Yarn est ajouté en tant que gestionnaire de paquets global.

6. **Installation d'Anchor et configuration via AVM**  
   Anchor est installé via Cargo en utilisant AVM (Anchor Version Manager) pour éviter certains problèmes de version.  
   Le script configure Anchor pour utiliser la version `0.30.1` (modifiable selon vos besoins).

7. **Installation de Solana CLI**  
   Solana est installé en exécutant un script depuis Anza.  
   La mise à jour du PATH permet d'accéder aux exécutables de Solana, Anchor et Cargo dans la session.

8. **Vérification des installations**  
   Des commandes sont exécutées pour vérifier et afficher les versions installées des principaux outils (Solana, Anchor, Rust, Node.js, Yarn).

9. **Configuration du répertoire de travail et point d'entrée**  
   Le répertoire de travail est défini à `/app`.  
   Le conteneur se lance dans un shell Bash interactif en mode login.

## Utilisation

Pour utiliser ce Dockerfile :

1. **Construire l'image Docker**  
   Dans le terminal, à la racine du dépôt contenant le Dockerfile, exécutez :
   ```bash
   docker build -t solana-dev .
   ```
   Cette commande construit l'image Docker en suivant les instructions décrites.

2. **Lancer un conteneur interactif**  
   Pour démarrer un conteneur et accéder à un terminal bash :
   ```bash
   docker run -it --rm -v $(pwd):/app solana-dev
   ```
   Vous serez connecté en tant qu'utilisateur `developer` avec toutes les dépendances et outils prêts à l'emploi.

3. **Développer et déployer**  
   Utilisez l'environnement pour compiler, développer et tester vos applications en Rust, Node.js ou Solana. Vous pouvez monter des volumes pour travailler sur votre code localement.

## Personnalisation

- **Versions des outils** : Vous pouvez modifier les versions de Anchor, Node.js ou d'autres composants en adaptant les commandes correspondantes dans le Dockerfile.
- **Ajout de nouvelles dépendances** : Pour ajouter d'autres packages ou outils, insérez les instructions `RUN apt-get install ...` ou les commandes d'installation spécifiques dans le Dockerfile.
- **Utilisation d'une autre base** : Bien que cette image utilise Ubuntu, vous pouvez la modifier pour une autre distribution si nécessaire.

## Crédits et licence

- **Auteur** : [Lejeune Pierre-Yves]
- **Licence** : Ce projet est sous licence [MIT]
