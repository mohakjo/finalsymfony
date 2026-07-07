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
