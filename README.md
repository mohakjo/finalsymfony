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
