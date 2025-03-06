from django.core.management.base import BaseCommand
from apps.users.models import UserProfile
import json
from datetime import datetime

class Command(BaseCommand):
    help = 'List all profiles in the database'

    def format_date(self, date):
        return date.strftime('%Y-%m-%d') if date else 'Not set'

    def handle(self, *args, **options):
        self.stdout.write('\nProfiles:')
        self.stdout.write('=' * 70)
        
        for profile in UserProfile.objects.all():
            # Basic Info
            self.stdout.write(f'Firebase UID: {profile.firebase_uid}')
            self.stdout.write(f'Name: {profile.first_name} {profile.last_name}')
            self.stdout.write(f'Date of Birth: {self.format_date(profile.date_of_birth)}')
            self.stdout.write(f'Bio: {profile.bio or "Not set"}')
            self.stdout.write(f'User Type: {profile.user_type}')
            
            # Profile Picture
            self.stdout.write(f'Profile Picture: {"Set" if profile.profile_picture else "Not set"}')
            
            # Demographics
            self.stdout.write('\nDemographics:')
            self.stdout.write(f'Gender: {profile.gender or "Not set"}')
            self.stdout.write(f'Race: {profile.race or "Not set"}')
            self.stdout.write(f'Disabilities: {profile.disabilities or "Not set"}')
            self.stdout.write(f'Military: {profile.military or "Not set"}')
            
            # Academic Info
            self.stdout.write('\nAcademic Information:')
            self.stdout.write(f'Grade Level: {profile.grade_level or "Not set"}')
            self.stdout.write(f'Financial Aid: {profile.financial_aid or "Not set"}')
            self.stdout.write(f'First Generation: {profile.first_gen or "Not set"}')
            self.stdout.write(f'Citizenship: {profile.citizenship or "Not set"}')
            self.stdout.write(f'Field of Study: {profile.field_of_study or "Not set"}')
            self.stdout.write(f'Career Goals: {profile.career_goals or "Not set"}')
            self.stdout.write(f'Education Level: {profile.education_level or "Not set"}')
            
            # Lists and JSON fields
            self.stdout.write('\nInterests and Skills:')
            self.stdout.write(f'Interests: {", ".join(profile.interests) if profile.interests else "None"}')
            self.stdout.write(f'Skills: {", ".join(profile.skills) if profile.skills else "None"}')
            
            # Education Details
            self.stdout.write('\nEducation Details:')
            if profile.education:
                self.stdout.write(json.dumps(profile.education, indent=2))
            else:
                self.stdout.write("No education details provided")
            
            # Credits
            self.stdout.write(f'\nCredits: {profile.credits}')
            
            self.stdout.write('-' * 70)

        # Summary
        self.stdout.write('\nSummary:')
        self.stdout.write('=' * 70)
        total_profiles = UserProfile.objects.count()
        complete_profiles = sum(1 for p in UserProfile.objects.all() if p.is_complete)
        self.stdout.write(f'Total Profiles: {total_profiles}')
        self.stdout.write(f'Complete Profiles: {complete_profiles}')
        self.stdout.write(f'Incomplete Profiles: {total_profiles - complete_profiles}') 