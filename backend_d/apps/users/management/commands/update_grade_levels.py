from django.core.management.base import BaseCommand
from django.db import connection

class Command(BaseCommand):
    help = 'Updates student grade levels based on current date'

    def handle(self, *args, **options):
        with connection.cursor() as cursor:
            cursor.execute("SELECT update_class_years();")
            self.stdout.write(self.style.SUCCESS('Successfully updated grade levels')) 