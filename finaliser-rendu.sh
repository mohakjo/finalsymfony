#!/usr/bin/env bash
set -e
echo "Finalisation du rendu..."
mkdir -p docs

cat > README.md <<'ENDOFFILE'
# Job Board — Plateforme de recrutement

Application web développée avec **Symfony 8** et Twig. Elle met en relation
candidats et recruteurs autour d'offres d'emploi : consultation et publication
d'offres, candidatures, espace d'administration, API JSON.

Projet de fin de cycle — sujet libre.

## Stack technique

- Symfony 8 / Twig
- Doctrine ORM avec héritage **Single Table Inheritance** (`User` → `Candidate`, `Recruiter`)
- Security Component : 3 rôles hiérarchisés + **Voter** personnalisé
- EasyAdmin 5 pour l'espace d'administration
- DoctrineFixturesBundle + Faker pour les données de test
- SQLite (aucun serveur de base de données à installer)

## Prérequis

- PHP 8.2 ou supérieur
- Composer
- (optionnel) Symfony CLI

## Installation

```bash
git clone https://github.com/mohakjo/finalsymfony.git
cd finalsymfony
composer install
```

La base est déjà configurée en SQLite dans le fichier `.env` (aucune configuration
supplémentaire nécessaire). Créer le schéma et charger les données :

```bash
php bin/console doctrine:migrations:migrate --no-interaction
php bin/console doctrine:fixtures:load --no-interaction
```

Lancer l'application :

```bash
symfony server:start
# ou, sans la CLI Symfony :
php -S 127.0.0.1:8000 -t public
```

L'application est accessible sur http://127.0.0.1:8000

## Comptes de test

Tous les comptes utilisent le mot de passe : `password`

| Rôle | Email |
|------|-------|
| Administrateur | admin@jobboard.test |
| Recruteur | recruteur@jobboard.test |
| Candidat | candidat@jobboard.test |

- Espace d'administration : `/admin` (compte administrateur)
- L'édition d'une offre (`/offers/{id}/edit`) n'est accessible qu'au recruteur
  auteur de l'offre ou à un administrateur (Voter `JobOfferVoter`).

## API JSON

```
GET /api/v1/offers        liste des offres publiées
GET /api/v1/offers/{id}   détail d'une offre
```

Les réponses exposent uniquement les champs publics des offres (pas de données
sensibles).

## Documentation

- `docs/cahier-des-charges.md` : description fonctionnelle, rôles et cas d'utilisation
- `docs/mcd.mermaid` : modèle de données (diagramme de classes)

## Perspectives

Prochaines étapes prévues : tests unitaires et fonctionnels (WebTestCase),
pipeline d'intégration continue (GitHub Actions), déploiement en ligne,
envoi d'e-mails transactionnels (Mailer) et consommation d'une API externe.
ENDOFFILE

cat > docs/cahier-des-charges.md <<'ENDOFFILE'
# Cahier des charges — Plateforme de recrutement (Job Board)

## 1. Description fonctionnelle

L'application est une plateforme de mise en relation entre candidats et recruteurs.
Les entreprises publient des offres d'emploi, les candidats consultent ces offres,
postulent avec un CV et une lettre de motivation, et échangent des messages avec les
recruteurs. Un espace d'administration permet de gérer l'ensemble des données.

Trois grands usages :
- Le candidat cherche un emploi, postule et suit ses candidatures.
- Le recruteur publie et gère les offres de son entreprise, et consulte les candidatures reçues.
- L'administrateur supervise toutes les données de la plateforme.

## 2. Rôles utilisateurs

| Rôle | Accès |
|------|-------|
| ROLE_USER (candidat) | Consultation des offres, candidature, gestion de son profil et de ses CV, messagerie |
| ROLE_RECRUITER | Tout ce que fait un candidat + création/édition/suppression de ses propres offres, consultation des candidatures reçues |
| ROLE_ADMIN | Accès complet à l'espace d'administration (CRUD sur toutes les entités, statistiques) |

Le modèle utilise l'héritage Doctrine (Single Table Inheritance) : une entité parente
`User` déclinée en `Candidate` et `Recruiter`.

## 3. Cas d'utilisation (Use Cases)

### Visiteur (non connecté)
- Consulter la liste des offres d'emploi
- Consulter le détail d'une offre
- Consulter la page d'une entreprise
- Créer un compte (candidat ou recruteur)
- Se connecter

### Candidat (ROLE_USER)
- Gérer son profil
- Ajouter / supprimer un CV
- Postuler à une offre (lettre de motivation + CV)
- Suivre le statut de ses candidatures
- Envoyer et recevoir des messages
- Recevoir des notifications (candidature acceptée / refusée)

### Recruteur (ROLE_RECRUITER)
- Créer une offre d'emploi liée à son entreprise
- Modifier / supprimer **uniquement ses propres** offres (Voter dédié)
- Consulter les candidatures reçues sur ses offres
- Changer le statut d'une candidature (envoi automatique d'un e-mail au candidat)
- Échanger des messages avec les candidats

### Administrateur (ROLE_ADMIN)
- Gérer (CRUD) l'ensemble des entités via l'espace d'administration
- Consulter des statistiques globales (nombre d'offres, de candidatures, d'utilisateurs)

## 4. Règles de gestion principales

- Une offre appartient à un recruteur et à une entreprise.
- Un recruteur ne peut modifier ou supprimer que les offres dont il est l'auteur.
- Une candidature associe un candidat, une offre et un CV.
- Un candidat ne peut postuler qu'une seule fois à une même offre.
- Le changement de statut d'une candidature déclenche une notification et un e-mail.
ENDOFFILE

cat > docs/mcd.mermaid <<'ENDOFFILE'
classDiagram
    class User {
        +int id
        +string email
        +json roles
        +string password
        +datetime createdAt
    }
    class Candidate {
        +string firstName
        +string lastName
        +string title
        +string bio
    }
    class Recruiter {
        +string firstName
        +string lastName
        +string position
    }
    class Company {
        +int id
        +string name
        +string description
        +string website
        +string city
    }
    class Category {
        +int id
        +string name
        +string slug
    }
    class JobOffer {
        +int id
        +string title
        +text description
        +string contractType
        +int salary
        +string location
        +string status
        +datetime createdAt
    }
    class Skill {
        +int id
        +string name
    }
    class Application {
        +int id
        +text coverLetter
        +string status
        +datetime createdAt
    }
    class Resume {
        +int id
        +string filename
        +datetime createdAt
    }
    class Message {
        +int id
        +text content
        +datetime createdAt
    }
    class Notification {
        +int id
        +string content
        +bool isRead
        +datetime createdAt
    }

    User <|-- Candidate : STI
    User <|-- Recruiter : STI

    Recruiter "1" --> "1" Company : travaille pour
    JobOffer "*" --> "1" Recruiter : publiee par
    JobOffer "*" --> "1" Company : chez
    JobOffer "*" --> "1" Category : dans
    Application "*" --> "1" JobOffer : concerne
    Application "*" --> "1" Candidate : envoyee par
    Application "*" --> "1" Resume : avec
    Resume "*" --> "1" Candidate : appartient a
    Message "*" --> "1" User : envoye par
    Message "*" --> "1" User : recu par
    Notification "*" --> "1" User : destinee a

    JobOffer "*" -- "*" Skill : requiert
    Candidate "*" -- "*" Skill : maitrise
ENDOFFILE

# Configurer SQLite dans le .env versionne (pour que le repo tourne apres un clone)
grep -v '^DATABASE_URL=' .env > .env.tmp
echo 'DATABASE_URL="sqlite:///%kernel.project_dir%/var/data.db"' >> .env.tmp
mv .env.tmp .env

echo "Termine : README + docs ajoutes, .env configure en SQLite."
