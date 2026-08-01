# MNote2

MNote2 est un éditeur de texte et de code multiplateforme développé avec Lazarus/Free Pascal. L'application combine l'édition par onglets, l'exécution de scripts, les outils de base de données, l'intégration IA, l'extraction de documents et des outils vocaux auxiliaires.

Version actuelle du code source : **2.64**.

## Captures

### Éditeur intégré
![Éditeur](screenshots/Editor%20com%20IA%20integrada.jpg)

### Gestion de fichiers
![Gestion des fichiers](screenshots/Gest%C3%A3o%20de%20Arquivos.jpg)

### Intelligence artificielle
![Utilisation de l’IA](screenshots/IA.jpg)

### Gestionnaire de base de données
![Base de données](screenshots/MQUERY.jpg)

## Fonctionnalités principales

### Éditeur et fichiers

- Éditeur multi-onglets basé sur SynEdit.
- Coloration syntaxique pour Pascal, Python, Java, SQL, PHP, C et d'autres types configurés via des listes auxiliaires.
- Recherche, remplacement, copier/coller, annuler/rétablir, sélection de blocs et configuration de police.
- Ouverture et enregistrement de fichiers dans des onglets indépendants.
- Extraction de texte depuis PDF, DOC et DOCX.
- Historique de conversation par fichier à l'aide de fichiers .RIA associés.
- Intégration avec l'organisation des dossiers et des projets.

### Projets, dossiers et analyse IA

- Parcours de dossiers avec analyse des fichiers source et des documents.
- Génère des résumés techniques par fichier en cache .RIA.
- Génère des analyses orientées question en cache .PIA.
- Supprime le cache .RIA lorsque le fichier source change après le résumé.
- Génère une carte mentale textuelle pour regrouper les points pertinents d'une question.
- Ignore automatiquement les fichiers cache .RIA et .PIA lors des nouvelles analyses.
- Prise en charge d'extensions telles que .pas, .pp, .lfm, .lpr, .ini, .json, .yml, .yaml, .php, .htm, .html, .js, .xml, .c, .cpp, .txt, .doc, .docx, .pdf, .sql, .jsp, .py, .cob et .md.

### Intelligence artificielle

- Client IA encapsulé dans TCHATGPT, version interne 1.5.
- Fournisseurs pris en charge : OpenAI, OpenRouter, Cerebras et Local/llama.cpp compatible avec l'API /v1/chat/completions.
- Modèles représentés dans le code : gpt-3.5-turbo, gpt-4, gpt-4-turbo-preview, gpt-4o, gpt-o3-mini, gpt-4.1, gpt-4.1-mini et gpt-5.
- Modèles locaux de type Ollama également représentés, notamment llama3.2:3b, Qwen et DeepSeek.
- Prise en charge d'un modèle personnalisé lorsqu'il est configuré.
- Configuration de l'endpoint local via IPLocalIA.
- Historique, carte mémoire et réflexion persistés dans des fichiers .RIA.
- Classification de la continuité de la conversation.
- Préparation du contexte à partir de l'historique, de la carte mémoire, du projet, de la base de données et des fichiers analysés.
- Actions assistées par l'IA, y compris la génération de requêtes SQL et la création de structures de tables.

### Python et automatisation

- Exécution de code Python ouvert dans l'éditeur via PythonEngine.
- Chemin de DLL Python configurable.
- Sortie d'exécution envoyée vers la zone de résultats.
- Inspection des variables globales et locales après l'exécution.
- Scripts externes configurables pour run, debug, clean, install et compile.
- Exemples dans sample/python, sample/gcc et scripts d'assistance dans src.

### Base de données et MQuery2

Le module MQuery2 sert de gestionnaire SQL intégré.

- Connexion à MySQL, PostgreSQL et SQLite via Zeos.
- Configuration des bibliothèques DLL/SO pour MySQL, PostgreSQL et SQLite.
- Navigation dans les arbres de bases de données, tables, champs, vues, procédures, fonctions, triggers et séquences selon la connexion active.
- Exécution libre de SQL depuis l'éditeur intégré.
- Génération de SQL à partir de tables sélectionnées.
- Création de tables à partir de jeux de données CSV.
- Création d'utilisateurs PostgreSQL.
- Génération de dictionnaires de données pour PostgreSQL et SQLite.
- Génération de listes de dépendances et de clés étrangères pour SQLite et PostgreSQL.
- Intégration IA pour analyser le SQL, suggérer des améliorations, embellir les requêtes et répondre à partir du DDL et des dépendances.
- TSQLiteDb fournit la connexion SQLite, les transactions, les pragmas recommandés, l'exécution paramétrée et des requêtes utilitaires.
- TProjetoDB ouvre le projet SQLite, vérifie les tables et charge les métadonnées et la configuration.

### Outils vocaux

- ToolsFalar envoie du texte via TCP vers un service de synthèse vocale comme srvFalar.
- ToolsOuvir se connecte via TCP pour recevoir des commandes et messages externes.
- Activation automatique optionnelle au démarrage selon la configuration.
- IP et port configurés via l'interface.

### Installation et distribution

- Installateur Windows basé sur Inno Setup dans instalador/MNote2.iss.
- Version de l'installateur Windows : 2.64.
- Copie MNote2.exe, les DLL, les fichiers .dci, les listes .txt, les scripts .bat, les exemples et la base par défaut.
- Copie la base par défaut dans C:db.
- Inclut une option post-installation pour lancer srvFalar_1.4.exe.
- Les paquets et binaires historiques se trouvent dans bin.
- buildlinux.sh maintient le flux de packaging Linux/deb.

## Structure du projet

- src/MNote2.lpr : point d'entrée de l'application Lazarus.
- src/main.pas : formulaire principal, onglets, éditeur, chargement/enregistrement, chat, historique, outils et intégration générale.
- src/classes/item.pas : encapsule chaque onglet/élément éditable, l'exécution Python et les scripts configurés.
- src/classes/chatgpt.pas : client HTTP pour les fournisseurs IA.
- src/setmain.pas : configuration globale et persistance dans mnote.cfg.
- src/config.pas : formulaire de configuration des scripts, DLL, IA, bases de données et outils TCP.
- src/folders.pas : gestion des dossiers, analyse de fichiers, caches .RIA/.PIA et analyse de projet par IA.
- src/ia.pas : interface IA avec historique, carte mémoire, réflexion, continuité et actions.
- src/mquery2/mquery2.pas : gestionnaire de bases de données et SQL.
- src/sqlite_db.pas : wrapper SQLite.
- src/uprojetodb.pas : chargement du projet SQLite et des métadonnées.
- src/uPdfText.pas : extraction native simple de texte PDF.
- src/uDocText.pas : extraction de texte DOC/DOCX.
- src/toolsfalar et src/toolsouvir : outils vocaux TCP.
- db/projeto_padrao.db : base de données par défaut du projet.
- screenshots : images utilisées par le README.
- instalador : scripts de packaging Windows.
- sample : exemples Python, C et traitement d'images.
- libs, sqlite et tools : bibliothèques et utilitaires externes fournis avec le projet.

## Exigences

### Développement

- Lazarus IDE et Free Pascal Compiler.
- Paquets Lazarus utilisés par le projet, notamment LCL, SynEdit, TAChart, Indy, Zeos, RX, Python4Lazarus, lNet et des composants supplémentaires listés dans src/MNote2.lpi.
- Bibliothèques de base de données selon les besoins : SQLite, client MySQL et PostgreSQL/libpq/ODBC selon la configuration.
- Python 3 compatible avec la DLL configurée lorsque l'exécution Python est activée.
- Inno Setup pour générer l'installateur Windows.

### Utilisation

- Windows et Linux sont les principales cibles représentées dans le projet.
- Les fichiers .doc classiques exigent Windows avec Microsoft Word installé.
- Les fonctions IA nécessitent un token/fournisseur configuré ou un serveur local compatible.
- Les outils vocaux nécessitent le service TCP correspondant en fonctionnement.

## Configuration

La configuration principale se trouve dans mnote.cfg et est gérée par TSetMain. Elle inclut :

- Position, taille de fenêtre et police.
- Fichiers récents.
- Scripts run/debug/clean/install/compile.
- Token IA et fournisseur.
- Endpoint IA local.
- Chemins des DLL Python, MySQL et PostgreSQL.
- Détails de connexion MySQL, PostgreSQL et SQLite.
- Activation et IP des outils ToolsFalar et ToolsOuvir.
- Dossier par défaut et projet courant.

Remarque : mnote.cfg peut contenir des tokens IA et des mots de passe de base de données. Protégez ce fichier localement.

## Utilisation rapide

1. Ouvrez MNote2.
2. Configurez les chemins DLL, scripts, bases de données et IA dans les paramètres.
3. Ouvrez ou créez des fichiers dans les onglets de l'éditeur.
4. Utilisez le menu de langage pour choisir le type de fichier/code.
5. Exécutez Python directement ou des scripts externes configurés.
6. Ouvrez MQuery2 pour vous connecter à MySQL, PostgreSQL ou SQLite.
7. Utilisez le panneau IA pour les questions avec historique, carte mémoire et analyse de projet.
8. Utilisez le gestionnaire de dossiers pour générer des résumés .RIA et des analyses .PIA.
9. Activez ToolsFalar/ToolsOuvir lorsque vous avez besoin d'une intégration vocale TCP.

## Notes de maintenance

- Le code actuel concentre une grande partie de la logique dans main.pas, folders.pas, ia.pas et mquery2.pas.
- Le dépôt versionne des binaires, des paquets et des bibliothèques externes car le projet distribue les artefacts avec le code source.
- Les fichiers .RIA et .PIA servent de cache/sortie IA et peuvent être régénérés par l'application.
- src/lib contient des artefacts de compilation Lazarus/Free Pascal pour les plateformes du projet.

## Licence

Voir le fichier LICENSE.
