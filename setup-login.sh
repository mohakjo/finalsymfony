#!/usr/bin/env bash
set -e
echo "Configuration securite + login + pages..."
mkdir -p config/packages src/Controller templates/home templates/offer templates/security

cat > config/packages/security.yaml <<'ENDOFFILE'
security:
    password_hashers:
        Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface: 'auto'

    providers:
        app_user_provider:
            entity:
                class: App\Entity\User
                property: email

    role_hierarchy:
        ROLE_RECRUITER: ROLE_USER
        ROLE_ADMIN: [ROLE_RECRUITER, ROLE_USER]

    firewalls:
        dev:
            pattern: ^/(_(profiler|wdt)|css|images|js)/
            security: false
        main:
            lazy: true
            provider: app_user_provider
            form_login:
                login_path: app_login
                check_path: app_login
                enable_csrf: true
                default_target_path: app_home
            logout:
                path: app_logout
                target: app_home

    access_control:
        - { path: ^/admin, roles: ROLE_ADMIN }
        - { path: ^/dashboard, roles: ROLE_USER }
ENDOFFILE

cat > src/Controller/HomeController.php <<'ENDOFFILE'
<?php

namespace App\Controller;

use App\Repository\JobOfferRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
    #[Route('/', name: 'app_home')]
    public function index(JobOfferRepository $jobOfferRepository): Response
    {
        return $this->render('home/index.html.twig', [
            'offers' => $jobOfferRepository->findBy(['status' => 'published'], ['createdAt' => 'DESC']),
        ]);
    }
}
ENDOFFILE

cat > src/Controller/SecurityController.php <<'ENDOFFILE'
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Authentication\AuthenticationUtils;

class SecurityController extends AbstractController
{
    #[Route('/login', name: 'app_login')]
    public function login(AuthenticationUtils $authenticationUtils): Response
    {
        $error = $authenticationUtils->getLastAuthenticationError();
        $lastUsername = $authenticationUtils->getLastUsername();

        return $this->render('security/login.html.twig', [
            'last_username' => $lastUsername,
            'error' => $error,
        ]);
    }

    #[Route('/logout', name: 'app_logout')]
    public function logout(): void
    {
        throw new \LogicException('Intercepte par la cle logout du firewall.');
    }
}
ENDOFFILE

cat > src/Controller/OfferController.php <<'ENDOFFILE'
<?php

namespace App\Controller;

use App\Entity\JobOffer;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class OfferController extends AbstractController
{
    #[Route('/offers/{id}', name: 'app_offer_show', requirements: ['id' => '\d+'])]
    public function show(JobOffer $offer): Response
    {
        return $this->render('offer/show.html.twig', [
            'offer' => $offer,
        ]);
    }
}
ENDOFFILE

cat > templates/base.html.twig <<'ENDOFFILE'
<!DOCTYPE html>
<html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>{% block title %}Job Board{% endblock %}</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 128 128%22><text y=%221.2em%22 font-size=%2296%22>💼</text></svg>">
        {% block stylesheets %}
        <style>
            :root { --bg:#0f172a; --card:#1e293b; --accent:#6366f1; --text:#e2e8f0; --muted:#94a3b8; }
            * { box-sizing: border-box; }
            body { margin:0; font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif; background:#f8fafc; color:#0f172a; }
            header { background:var(--bg); color:#fff; padding:1rem 2rem; display:flex; justify-content:space-between; align-items:center; }
            header a { color:#fff; text-decoration:none; margin-left:1.25rem; font-size:.95rem; }
            header .brand { font-weight:700; font-size:1.2rem; margin:0; }
            header .brand a { margin:0; }
            main { max-width:960px; margin:0 auto; padding:2rem; }
            .btn { display:inline-block; background:var(--accent); color:#fff !important; padding:.55rem 1.1rem; border-radius:8px; text-decoration:none; border:none; font-size:.95rem; cursor:pointer; }
            .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:1rem; }
            .card { background:#fff; border:1px solid #e2e8f0; border-radius:12px; padding:1.25rem; }
            .card h3 { margin:0 0 .5rem; }
            .card a { color:#4338ca; text-decoration:none; }
            .tag { display:inline-block; background:#eef2ff; color:#4338ca; padding:.2rem .6rem; border-radius:999px; font-size:.78rem; margin:.15rem .15rem 0 0; }
            .muted { color:#64748b; font-size:.9rem; }
            form.login { max-width:360px; margin:2rem auto; background:#fff; padding:2rem; border-radius:12px; border:1px solid #e2e8f0; }
            form.login label { display:block; margin:.75rem 0 .25rem; font-size:.9rem; }
            form.login input { width:100%; padding:.6rem; border:1px solid #cbd5e1; border-radius:8px; }
            form.login button { margin-top:1.25rem; width:100%; }
            .alert { background:#fee2e2; color:#991b1b; padding:.6rem .8rem; border-radius:8px; font-size:.9rem; }
            .hint { background:#f1f5f9; padding:.8rem; border-radius:8px; font-size:.82rem; margin-top:1rem; color:#475569; }
        </style>
        {% endblock %}
        {% block javascripts %}
            {% block importmap %}{{ importmap('app') }}{% endblock %}
        {% endblock %}
    </head>
    <body>
        <header>
            <p class="brand"><a href="{{ path('app_home') }}">💼 Job Board</a></p>
            <nav>
                <a href="{{ path('app_home') }}">Offres</a>
                {% if app.user %}
                    {% if is_granted('ROLE_ADMIN') %}<a href="/admin">Admin</a>{% endif %}
                    <a href="{{ path('app_logout') }}">Déconnexion ({{ app.user.email }})</a>
                {% else %}
                    <a href="{{ path('app_login') }}">Connexion</a>
                {% endif %}
            </nav>
        </header>
        <main>
            {% block body %}{% endblock %}
        </main>
    </body>
</html>
ENDOFFILE

cat > templates/home/index.html.twig <<'ENDOFFILE'
{% extends 'base.html.twig' %}

{% block title %}Offres d'emploi — Job Board{% endblock %}

{% block body %}
    <h1>Offres d'emploi</h1>
    <p class="muted">{{ offers|length }} offre(s) disponible(s)</p>

    <div class="grid">
        {% for offer in offers %}
            <div class="card">
                <h3><a href="{{ path('app_offer_show', {id: offer.id}) }}">{{ offer.title }}</a></h3>
                <p class="muted">{{ offer.company.name }} · {{ offer.location }}</p>
                <span class="tag">{{ offer.contractType }}</span>
                {% if offer.category %}<span class="tag">{{ offer.category.name }}</span>{% endif %}
            </div>
        {% else %}
            <p>Aucune offre pour le moment.</p>
        {% endfor %}
    </div>
{% endblock %}
ENDOFFILE

cat > templates/offer/show.html.twig <<'ENDOFFILE'
{% extends 'base.html.twig' %}

{% block title %}{{ offer.title }} — Job Board{% endblock %}

{% block body %}
    <p><a href="{{ path('app_home') }}">← Retour aux offres</a></p>
    <h1>{{ offer.title }}</h1>
    <p class="muted">{{ offer.company.name }} · {{ offer.location }}</p>

    <p>
        <span class="tag">{{ offer.contractType }}</span>
        {% if offer.category %}<span class="tag">{{ offer.category.name }}</span>{% endif %}
        {% if offer.salary %}<span class="tag">{{ offer.salary }} € / an</span>{% endif %}
    </p>

    {% if offer.skills|length > 0 %}
        <p><strong>Compétences :</strong>
            {% for skill in offer.skills %}<span class="tag">{{ skill.name }}</span>{% endfor %}
        </p>
    {% endif %}

    <h3>Description</h3>
    <p style="white-space:pre-line;">{{ offer.description }}</p>

    <p class="muted">Publiée par {{ offer.recruiter.firstName }} {{ offer.recruiter.lastName }}
        le {{ offer.createdAt|date('d/m/Y') }}</p>
{% endblock %}
ENDOFFILE

cat > templates/security/login.html.twig <<'ENDOFFILE'
{% extends 'base.html.twig' %}

{% block title %}Connexion — Job Board{% endblock %}

{% block body %}
    <form class="login" method="post">
        <h1 style="margin-top:0;">Connexion</h1>

        {% if error %}
            <div class="alert">{{ error.messageKey|trans(error.messageData, 'security') }}</div>
        {% endif %}

        <label for="username">Email</label>
        <input type="email" id="username" name="_username" value="{{ last_username }}" required autofocus>

        <label for="password">Mot de passe</label>
        <input type="password" id="password" name="_password" required>

        <input type="hidden" name="_csrf_token" value="{{ csrf_token('authenticate') }}">

        <button class="btn" type="submit">Se connecter</button>

        <div class="hint">
            Comptes de test (mot de passe : <strong>password</strong>)<br>
            admin@jobboard.test · recruteur@jobboard.test · candidat@jobboard.test
        </div>
    </form>
{% endblock %}
ENDOFFILE

echo "Termine : securite, login et pages creees."
