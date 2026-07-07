<?php

namespace App\Controller;

use App\Entity\JobOffer;
use App\Repository\JobOfferRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

class ApiController extends AbstractController
{
    #[Route('/api/v1/offers', name: 'api_offers_index', methods: ['GET'])]
    public function offers(JobOfferRepository $jobOfferRepository): JsonResponse
    {
        $offers = $jobOfferRepository->findBy(['status' => 'published'], ['createdAt' => 'DESC']);
        $data = array_map(fn (JobOffer $offer) => $this->serializeOffer($offer), $offers);

        return $this->json([
            'count' => count($data),
            'data' => $data,
        ]);
    }

    #[Route('/api/v1/offers/{id}', name: 'api_offers_show', methods: ['GET'], requirements: ['id' => '\d+'])]
    public function offer(JobOffer $offer): JsonResponse
    {
        return $this->json($this->serializeOffer($offer));
    }

    private function serializeOffer(JobOffer $offer): array
    {
        $recruiter = $offer->getRecruiter();

        return [
            'id' => $offer->getId(),
            'title' => $offer->getTitle(),
            'description' => $offer->getDescription(),
            'contractType' => $offer->getContractType(),
            'salary' => $offer->getSalary(),
            'location' => $offer->getLocation(),
            'status' => $offer->getStatus(),
            'createdAt' => $offer->getCreatedAt()?->format(\DateTimeInterface::ATOM),
            'company' => $offer->getCompany()?->getName(),
            'category' => $offer->getCategory()?->getName(),
            'recruiter' => $recruiter ? trim($recruiter->getFirstName() . ' ' . $recruiter->getLastName()) : null,
            'skills' => array_map(fn ($skill) => $skill->getName(), $offer->getSkills()->toArray()),
        ];
    }
}
