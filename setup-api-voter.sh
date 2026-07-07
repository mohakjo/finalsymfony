#!/usr/bin/env bash
set -e
echo "API JSON + Voter..."
mkdir -p src/Entity src/Controller src/Security/Voter templates/offer

cat > src/Entity/JobOffer.php <<'ENDOFFILE'
<?php

namespace App\Entity;

use App\Repository\JobOfferRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: JobOfferRepository::class)]
class JobOffer
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 200)]
    private ?string $title = null;

    #[ORM\Column(type: 'text')]
    private ?string $description = null;

    #[ORM\Column(length: 50)]
    private ?string $contractType = null;

    #[ORM\Column(nullable: true)]
    private ?int $salary = null;

    #[ORM\Column(length: 120)]
    private ?string $location = null;

    #[ORM\Column(length: 30)]
    private ?string $status = 'published';

    #[ORM\Column]
    private ?\DateTimeImmutable $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Recruiter::class, inversedBy: 'jobOffers')]
    private ?Recruiter $recruiter = null;

    #[ORM\ManyToOne(targetEntity: Company::class, inversedBy: 'jobOffers')]
    private ?Company $company = null;

    #[ORM\ManyToOne(targetEntity: Category::class, inversedBy: 'jobOffers')]
    private ?Category $category = null;

    #[ORM\ManyToMany(targetEntity: Skill::class, inversedBy: 'jobOffers')]
    private Collection $skills;

    #[ORM\OneToMany(mappedBy: 'jobOffer', targetEntity: Application::class, orphanRemoval: true)]
    private Collection $applications;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
        $this->skills = new ArrayCollection();
        $this->applications = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getTitle(): ?string
    {
        return $this->title;
    }

    public function setTitle(string $title): static
    {
        $this->title = $title;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getContractType(): ?string
    {
        return $this->contractType;
    }

    public function setContractType(string $contractType): static
    {
        $this->contractType = $contractType;
        return $this;
    }

    public function getSalary(): ?int
    {
        return $this->salary;
    }

    public function setSalary(?int $salary): static
    {
        $this->salary = $salary;
        return $this;
    }

    public function getLocation(): ?string
    {
        return $this->location;
    }

    public function setLocation(string $location): static
    {
        $this->location = $location;
        return $this;
    }

    public function getStatus(): ?string
    {
        return $this->status;
    }

    public function setStatus(string $status): static
    {
        $this->status = $status;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function setCreatedAt(\DateTimeImmutable $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getRecruiter(): ?Recruiter
    {
        return $this->recruiter;
    }

    public function setRecruiter(?Recruiter $recruiter): static
    {
        $this->recruiter = $recruiter;
        return $this;
    }

    public function getCompany(): ?Company
    {
        return $this->company;
    }

    public function setCompany(?Company $company): static
    {
        $this->company = $company;
        return $this;
    }

    public function getCategory(): ?Category
    {
        return $this->category;
    }

    public function setCategory(?Category $category): static
    {
        $this->category = $category;
        return $this;
    }

    public function getSkills(): Collection
    {
        return $this->skills;
    }

    public function addSkill(Skill $skill): static
    {
        if (!$this->skills->contains($skill)) {
            $this->skills->add($skill);
        }
        return $this;
    }

    public function removeSkill(Skill $skill): static
    {
        $this->skills->removeElement($skill);
        return $this;
    }

    public function getApplications(): Collection
    {
        return $this->applications;
    }

    public function addApplication(Application $application): static
    {
        if (!$this->applications->contains($application)) {
            $this->applications->add($application);
            $application->setJobOffer($this);
        }
        return $this;
    }

    public function removeApplication(Application $application): static
    {
        if ($this->applications->removeElement($application)) {
            if ($application->getJobOffer() === $this) {
                $application->setJobOffer(null);
            }
        }
        return $this;
    }
}
ENDOFFILE

cat > src/Entity/Company.php <<'ENDOFFILE'
<?php

namespace App\Entity;

use App\Repository\CompanyRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: CompanyRepository::class)]
class Company
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 150)]
    private ?string $name = null;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $description = null;

    #[ORM\Column(length: 255, nullable: true)]
    private ?string $website = null;

    #[ORM\Column(length: 100, nullable: true)]
    private ?string $city = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $createdAt = null;

    #[ORM\OneToMany(mappedBy: 'company', targetEntity: Recruiter::class)]
    private Collection $recruiters;

    #[ORM\OneToMany(mappedBy: 'company', targetEntity: JobOffer::class)]
    private Collection $jobOffers;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
        $this->recruiters = new ArrayCollection();
        $this->jobOffers = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getWebsite(): ?string
    {
        return $this->website;
    }

    public function setWebsite(?string $website): static
    {
        $this->website = $website;
        return $this;
    }

    public function getCity(): ?string
    {
        return $this->city;
    }

    public function setCity(?string $city): static
    {
        $this->city = $city;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function setCreatedAt(\DateTimeImmutable $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getRecruiters(): Collection
    {
        return $this->recruiters;
    }

    public function getJobOffers(): Collection
    {
        return $this->jobOffers;
    }
}
ENDOFFILE

cat > src/Entity/Category.php <<'ENDOFFILE'
<?php

namespace App\Entity;

use App\Repository\CategoryRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: CategoryRepository::class)]
class Category
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 100)]
    private ?string $name = null;

    #[ORM\Column(length: 120)]
    private ?string $slug = null;

    #[ORM\OneToMany(mappedBy: 'category', targetEntity: JobOffer::class)]
    private Collection $jobOffers;

    public function __construct()
    {
        $this->jobOffers = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }

    public function getSlug(): ?string
    {
        return $this->slug;
    }

    public function setSlug(string $slug): static
    {
        $this->slug = $slug;
        return $this;
    }

    public function getJobOffers(): Collection
    {
        return $this->jobOffers;
    }
}
ENDOFFILE

cat > src/Entity/Skill.php <<'ENDOFFILE'
<?php

namespace App\Entity;

use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity]
class Skill
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 80)]
    private ?string $name = null;

    #[ORM\ManyToMany(targetEntity: JobOffer::class, mappedBy: 'skills')]
    private Collection $jobOffers;

    #[ORM\ManyToMany(targetEntity: Candidate::class, mappedBy: 'skills')]
    private Collection $candidates;

    public function __construct()
    {
        $this->jobOffers = new ArrayCollection();
        $this->candidates = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }

    public function getJobOffers(): Collection
    {
        return $this->jobOffers;
    }

    public function getCandidates(): Collection
    {
        return $this->candidates;
    }
}
ENDOFFILE

cat > src/Entity/User.php <<'ENDOFFILE'
<?php

namespace App\Entity;

use App\Repository\UserRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;

#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: 'app_user')]
#[ORM\InheritanceType('SINGLE_TABLE')]
#[ORM\DiscriminatorColumn(name: 'type', type: 'string')]
#[ORM\DiscriminatorMap(['user' => User::class, 'candidate' => Candidate::class, 'recruiter' => Recruiter::class])]
class User implements UserInterface, PasswordAuthenticatedUserInterface
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    protected ?int $id = null;

    #[ORM\Column(length: 180, unique: true)]
    protected ?string $email = null;

    #[ORM\Column]
    protected array $roles = [];

    #[ORM\Column]
    protected ?string $password = null;

    #[ORM\Column(length: 100, nullable: true)]
    protected ?string $firstName = null;

    #[ORM\Column(length: 100, nullable: true)]
    protected ?string $lastName = null;

    #[ORM\Column]
    protected ?\DateTimeImmutable $createdAt = null;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function setEmail(string $email): static
    {
        $this->email = $email;
        return $this;
    }

    public function getUserIdentifier(): string
    {
        return (string) $this->email;
    }

    public function getRoles(): array
    {
        $roles = $this->roles;
        $roles[] = 'ROLE_USER';
        return array_unique($roles);
    }

    public function setRoles(array $roles): static
    {
        $this->roles = $roles;
        return $this;
    }

    public function getPassword(): ?string
    {
        return $this->password;
    }

    public function setPassword(string $password): static
    {
        $this->password = $password;
        return $this;
    }

    public function getFirstName(): ?string
    {
        return $this->firstName;
    }

    public function setFirstName(?string $firstName): static
    {
        $this->firstName = $firstName;
        return $this;
    }

    public function getLastName(): ?string
    {
        return $this->lastName;
    }

    public function setLastName(?string $lastName): static
    {
        $this->lastName = $lastName;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function setCreatedAt(\DateTimeImmutable $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function eraseCredentials(): void
    {
    }
}
ENDOFFILE

cat > src/Controller/ApiController.php <<'ENDOFFILE'
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
ENDOFFILE

cat > src/Controller/OfferController.php <<'ENDOFFILE'
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
ENDOFFILE

cat > src/Security/Voter/JobOfferVoter.php <<'ENDOFFILE'
<?php

namespace App\Security\Voter;

use App\Entity\JobOffer;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;

class JobOfferVoter extends Voter
{
    public const EDIT = 'JOB_OFFER_EDIT';
    public const DELETE = 'JOB_OFFER_DELETE';

    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, [self::EDIT, self::DELETE], true) && $subject instanceof JobOffer;
    }

    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();

        if (!$user instanceof User) {
            return false;
        }

        if (in_array('ROLE_ADMIN', $user->getRoles(), true)) {
            return true;
        }

        /** @var JobOffer $subject */
        return $subject->getRecruiter() === $user;
    }
}
ENDOFFILE

cat > templates/offer/show.html.twig <<'ENDOFFILE'
{% extends 'base.html.twig' %}

{% block title %}{{ offer.title }} — Job Board{% endblock %}

{% block body %}
    <p><a href="{{ path('app_home') }}">← Retour aux offres</a></p>
    <h1>{{ offer.title }}</h1>
    <p class="muted">{{ offer.company.name }} · {{ offer.location }}</p>

    {% if is_granted('JOB_OFFER_EDIT', offer) %}
        <p><a class="btn" href="{{ path('app_offer_edit', {id: offer.id}) }}">Modifier cette offre</a></p>
    {% endif %}

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

cat > templates/offer/edit.html.twig <<'ENDOFFILE'
{% extends 'base.html.twig' %}

{% block title %}Modifier — {{ offer.title }}{% endblock %}

{% block body %}
    <p><a href="{{ path('app_offer_show', {id: offer.id}) }}">← Retour à l'offre</a></p>
    <h1>Modifier l'offre</h1>
    {{ form(form) }}
{% endblock %}
ENDOFFILE

echo "Termine : API JSON + Voter en place."
