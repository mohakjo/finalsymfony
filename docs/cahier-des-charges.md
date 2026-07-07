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
