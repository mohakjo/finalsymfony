<?php

namespace App\Controller\Admin;

use EasyCorp\Bundle\EasyAdminBundle\Attribute\AdminDashboard;
use EasyCorp\Bundle\EasyAdminBundle\Config\Dashboard;
use EasyCorp\Bundle\EasyAdminBundle\Config\MenuItem;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractDashboardController;
use EasyCorp\Bundle\EasyAdminBundle\Router\AdminUrlGenerator;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[AdminDashboard(routePath: '/admin', routeName: 'admin')]
#[IsGranted('ROLE_ADMIN')]
class DashboardController extends AbstractDashboardController
{
    public function __construct(private AdminUrlGenerator $adminUrlGenerator)
    {
    }

    public function index(): Response
    {
        return $this->redirect(
            $this->adminUrlGenerator->setController(JobOfferCrudController::class)->generateUrl()
        );
    }

    public function configureDashboard(): Dashboard
    {
        return Dashboard::new()
            ->setTitle('Job Board — Administration');
    }

    public function configureMenuItems(): iterable
    {
        yield MenuItem::linkToDashboard('Tableau de bord', 'fa fa-home');

        yield MenuItem::section('Recrutement');
        yield MenuItem::linkTo(JobOfferCrudController::class, 'Offres', 'fa fa-briefcase');
        yield MenuItem::linkTo(ApplicationCrudController::class, 'Candidatures', 'fa fa-file-lines');
        yield MenuItem::linkTo(CompanyCrudController::class, 'Entreprises', 'fa fa-building');
        yield MenuItem::linkTo(CategoryCrudController::class, 'Categories', 'fa fa-tags');
        yield MenuItem::linkTo(SkillCrudController::class, 'Competences', 'fa fa-star');

        yield MenuItem::section('Utilisateurs');
        yield MenuItem::linkTo(UserCrudController::class, 'Tous les comptes', 'fa fa-users');
        yield MenuItem::linkTo(CandidateCrudController::class, 'Candidats', 'fa fa-user');
        yield MenuItem::linkTo(RecruiterCrudController::class, 'Recruteurs', 'fa fa-user-tie');

        yield MenuItem::section('Autres');
        yield MenuItem::linkTo(ResumeCrudController::class, 'CV', 'fa fa-file');
        yield MenuItem::linkTo(MessageCrudController::class, 'Messages', 'fa fa-envelope');
        yield MenuItem::linkTo(NotificationCrudController::class, 'Notifications', 'fa fa-bell');
    }
}
