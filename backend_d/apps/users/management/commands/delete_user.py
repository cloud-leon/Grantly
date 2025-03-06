from django.core.management.base import BaseCommand
from apps.users.models import UserProfile, User

class Command(BaseCommand):
    help = 'Delete user and profile by Firebase UID'

    def add_arguments(self, parser):
        parser.add_argument('firebase_uid', type=str)

    def handle(self, *args, **options):
        firebase_uid = options['firebase_uid']
        
        try:
            # First find the profile by firebase_uid
            profile = UserProfile.objects.get(firebase_uid=firebase_uid)
            
            # Get the associated user before deleting the profile
            user = profile.user
            
            # Delete the profile
            profile.delete()
            self.stdout.write(self.style.SUCCESS(f'Successfully deleted profile for {firebase_uid}'))
            
            # Delete the user
            if user:
                user.delete()
                self.stdout.write(self.style.SUCCESS(f'Successfully deleted user {user.email}'))
                
        except UserProfile.DoesNotExist:
            self.stdout.write(self.style.WARNING(f'Profile not found for {firebase_uid}')) 