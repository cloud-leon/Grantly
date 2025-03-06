from django.core.management.base import BaseCommand
from apps.users.models import User, UserProfile
from django.db import transaction

class Command(BaseCommand):
    help = 'Clear all users and profiles from the database'

    def add_arguments(self, parser):
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force deletion without confirmation',
        )

    def handle(self, *args, **options):
        if not options['force']:
            confirm = input('This will delete ALL users and profiles. Are you sure? (y/N): ')
            if confirm.lower() != 'y':
                self.stdout.write(self.style.WARNING('Operation cancelled'))
                return

        with transaction.atomic():
            profiles_count = UserProfile.objects.count()
            users_count = User.objects.count()
            
            UserProfile.objects.all().delete()
            User.objects.all().delete()
            
            self.stdout.write(
                self.style.SUCCESS(
                    f'Successfully deleted {profiles_count} profiles and {users_count} users'
                )
            ) 