<?php

namespace App\Controller;

use App\Entity\JobOffer;
use App\Security\Voter\JobOfferVoter;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Form\Extension\Core\Type\IntegerType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\HttpFoundation\Request;
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

    #[Route('/offers/{id}/edit', name: 'app_offer_edit', requirements: ['id' => '\d+'])]
    public function edit(Request $request, JobOffer $offer, EntityManagerInterface $entityManager): Response
    {
        $this->denyAccessUnlessGranted(JobOfferVoter::EDIT, $offer);

        $form = $this->createFormBuilder($offer)
            ->add('title', TextType::class, ['label' => 'Titre'])
            ->add('location', TextType::class, ['label' => 'Lieu'])
            ->add('contractType', TextType::class, ['label' => 'Type de contrat'])
            ->add('salary', IntegerType::class, ['label' => 'Salaire annuel', 'required' => false])
            ->add('description', TextareaType::class, ['label' => 'Description'])
            ->add('save', SubmitType::class, ['label' => 'Enregistrer'])
            ->getForm();

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $entityManager->flush();

            return $this->redirectToRoute('app_offer_show', ['id' => $offer->getId()]);
        }

        return $this->render('offer/edit.html.twig', [
            'form' => $form,
            'offer' => $offer,
        ]);
    }
}
