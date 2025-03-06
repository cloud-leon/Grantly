from django.core.management.base import BaseCommand
from apps.users.models import User, UserProfile
from django.db import transaction

class Command(BaseCommand):
    help = 'Cleanup users and profiles'

    def handle(self, *args, **kwargs):
        with transaction.atomic():
            # Delete profiles with empty firebase_uid
            profiles_deleted = UserProfile.objects.filter(firebase_uid__isnull=True).delete()
            self.stdout.write(f"Deleted {profiles_deleted[0]} profiles with null firebase_uid")
            
            profiles_deleted = UserProfile.objects.filter(firebase_uid='').delete()
            self.stdout.write(f"Deleted {profiles_deleted[0]} profiles with empty firebase_uid")

            # Delete users with empty firebase_uid
            users_deleted = User.objects.filter(firebase_uid__isnull=True).delete()
            self.stdout.write(f"Deleted {users_deleted[0]} users with null firebase_uid")
            
            users_deleted = User.objects.filter(firebase_uid='').delete()
            self.stdout.write(f"Deleted {users_deleted[0]} users with empty firebase_uid")

            # Delete specific user if needed
            specific_uid = '7dvKff0MxsYnOh2aU8JqYU5p2E22'
            UserProfile.objects.filter(firebase_uid=specific_uid).delete()
            User.objects.filter(firebase_uid=specific_uid).delete()
            self.stdout.write(f"Deleted user and profile with firebase_uid {specific_uid}") 