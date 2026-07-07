#!/usr/bin/env bash
set -e
echo "Creation des fixtures..."
mkdir -p src/DataFixtures

cat > src/DataFixtures/AppFixtures.php <<'ENDOFPHP'
<?php

namespace App\DataFixtures;

use App\Entity\Application;
use App\Entity\Candidate;
use App\Entity\Category;
use App\Entity\Company;
use App\Entity\JobOffer;
use App\Entity\Message;
use App\Entity\Notification;
use App\Entity\Recruiter;
use App\Entity\Resume;
use App\Entity\Skill;
use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class AppFixtures extends Fixture
{
    public function __construct(private UserPasswordHasherInterface $hasher)
    {
    }

    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create('fr_FR');

        $admin = new User();
        $admin->setEmail('admin@jobboard.test');
        $admin->setRoles(['ROLE_ADMIN']);
        $admin->setFirstName('Admin');
        $admin->setLastName('Jobboard');
        $admin->setPassword($this->hasher->hashPassword($admin, 'password'));
        $manager->persist($admin);

        $categories = [];
        foreach (['Developpement', 'Design', 'Marketing', 'Data', 'Support', 'Ressources Humaines'] as $name) {
            $category = new Category();
            $category->setName($name);
            $category->setSlug(strtolower($name));
            $manager->persist($category);
            $categories[] = $category;
        }

        $skills = [];
        foreach (['PHP', 'Symfony', 'JavaScript', 'Vue.js', 'SQL', 'Docker', 'Figma', 'SEO', 'Python', 'Git'] as $name) {
            $skill = new Skill();
            $skill->setName($name);
            $manager->persist($skill);
            $skills[] = $skill;
        }

        $companies = [];
        for ($i = 0; $i < 6; $i++) {
            $company = new Company();
            $company->setName($faker->company());
            $company->setDescription($faker->catchPhrase());
            $company->setWebsite('https://' . $faker->domainName());
            $company->setCity($faker->city());
            $manager->persist($company);
            $companies[] = $company;
        }

        $recruiters = [];

        $mainRecruiter = new Recruiter();
        $mainRecruiter->setEmail('recruteur@jobboard.test');
        $mainRecruiter->setRoles(['ROLE_RECRUITER']);
        $mainRecruiter->setFirstName('Claire');
        $mainRecruiter->setLastName('Martin');
        $mainRecruiter->setPosition('Responsable recrutement');
        $mainRecruiter->setCompany($companies[0]);
        $mainRecruiter->setPassword($this->hasher->hashPassword($mainRecruiter, 'password'));
        $manager->persist($mainRecruiter);
        $recruiters[] = $mainRecruiter;

        for ($i = 0; $i < 5; $i++) {
            $recruiter = new Recruiter();
            $recruiter->setEmail($faker->unique()->companyEmail());
            $recruiter->setRoles(['ROLE_RECRUITER']);
            $recruiter->setFirstName($faker->firstName());
            $recruiter->setLastName($faker->lastName());
            $recruiter->setPosition($faker->jobTitle());
            $recruiter->setCompany($faker->randomElement($companies));
            $recruiter->setPassword($this->hasher->hashPassword($recruiter, 'password'));
            $manager->persist($recruiter);
            $recruiters[] = $recruiter;
        }

        $candidates = [];

        $mainCandidate = new Candidate();
        $mainCandidate->setEmail('candidat@jobboard.test');
        $mainCandidate->setRoles(['ROLE_USER']);
        $mainCandidate->setFirstName('Yanis');
        $mainCandidate->setLastName('Dubois');
        $mainCandidate->setTitle('Developpeur web junior');
        $mainCandidate->setBio($faker->paragraph());
        $mainCandidate->setPassword($this->hasher->hashPassword($mainCandidate, 'password'));
        foreach ($faker->randomElements($skills, 3) as $skill) {
            $mainCandidate->addSkill($skill);
        }
        $manager->persist($mainCandidate);
        $candidates[] = $mainCandidate;

        for ($i = 0; $i < 10; $i++) {
            $candidate = new Candidate();
            $candidate->setEmail($faker->unique()->safeEmail());
            $candidate->setRoles(['ROLE_USER']);
            $candidate->setFirstName($faker->firstName());
            $candidate->setLastName($faker->lastName());
            $candidate->setTitle($faker->jobTitle());
            $candidate->setBio($faker->paragraph());
            $candidate->setPassword($this->hasher->hashPassword($candidate, 'password'));
            foreach ($faker->randomElements($skills, $faker->numberBetween(2, 4)) as $skill) {
                $candidate->addSkill($skill);
            }
            $manager->persist($candidate);
            $candidates[] = $candidate;
        }

        $resumes = [];
        foreach ($candidates as $candidate) {
            $nb = $faker->numberBetween(1, 2);
            for ($i = 0; $i < $nb; $i++) {
                $resume = new Resume();
                $resume->setFilename('cv_' . $faker->uuid() . '.pdf');
                $resume->setCandidate($candidate);
                $manager->persist($resume);
                $resumes[$candidate->getEmail()][] = $resume;
            }
        }

        $contracts = ['CDI', 'CDD', 'Stage', 'Alternance', 'Freelance'];
        $offers = [];
        for ($i = 0; $i < 15; $i++) {
            $offer = new JobOffer();
            $offer->setTitle($faker->jobTitle());
            $offer->setDescription($faker->paragraphs(3, true));
            $offer->setContractType($faker->randomElement($contracts));
            $offer->setSalary($faker->numberBetween(28000, 65000));
            $offer->setLocation($faker->city());
            $offer->setStatus('published');
            $offer->setRecruiter($faker->randomElement($recruiters));
            $offer->setCompany($offer->getRecruiter()->getCompany());
            $offer->setCategory($faker->randomElement($categories));
            foreach ($faker->randomElements($skills, $faker->numberBetween(2, 4)) as $skill) {
                $offer->addSkill($skill);
            }
            $manager->persist($offer);
            $offers[] = $offer;
        }

        $statuses = ['pending', 'accepted', 'rejected'];
        for ($i = 0; $i < 25; $i++) {
            $candidate = $faker->randomElement($candidates);
            $application = new Application();
            $application->setCoverLetter($faker->paragraphs(2, true));
            $application->setStatus($faker->randomElement($statuses));
            $application->setJobOffer($faker->randomElement($offers));
            $application->setCandidate($candidate);
            $application->setResume($faker->randomElement($resumes[$candidate->getEmail()]));
            $manager->persist($application);
        }

        $allUsers = array_merge($recruiters, $candidates);
        for ($i = 0; $i < 12; $i++) {
            $message = new Message();
            $message->setContent($faker->sentence());
            $message->setSender($faker->randomElement($allUsers));
            $message->setReceiver($faker->randomElement($allUsers));
            $manager->persist($message);
        }

        foreach ($candidates as $candidate) {
            $notification = new Notification();
            $notification->setContent('Votre candidature a ete consultee.');
            $notification->setIsRead($faker->boolean());
            $notification->setUser($candidate);
            $manager->persist($notification);
        }

        $manager->flush();
    }
}
ENDOFPHP

echo "Termine : fixtures creees."
