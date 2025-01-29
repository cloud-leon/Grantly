from django.contrib.auth.models import AbstractUser
from django.db import models

# Create your models here.

class User(AbstractUser):
    USER_TYPE_CHOICES = (
        ('student', 'Student'),
        ('admin', 'Admin'),
        # Add other user types as needed
    )
    
    user_type = models.CharField(
        max_length=20,
        choices=USER_TYPE_CHOICES,
        default='student'
    )
    date_of_birth = models.DateField(null=True, blank=True)
    bio = models.CharField(max_length=500, blank=True)

    class Meta:
        db_table = 'users'
