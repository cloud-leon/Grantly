from django.contrib.auth.models import AbstractUser
from django.db import models
from phonenumber_field.modelfields import PhoneNumberField

# Create your models here.

class User(AbstractUser):
    USER_TYPES = [
        ('student', 'Student'),
        ('admin', 'Admin'),
    ]
    
    user_type = models.CharField(
        max_length=10,
        choices=USER_TYPES,
        default='student'
    )
    date_of_birth = models.DateField(null=True, blank=True)
    bio = models.TextField(max_length=500, blank=True)
    interests = models.JSONField(default=list, blank=True)  # Store as list of strings
    education = models.JSONField(default=dict, blank=True)  # Store education history
    skills = models.JSONField(default=list, blank=True)  # Store as list of strings
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    phone_number = PhoneNumberField(unique=True, null=True, blank=True)
    location = models.CharField(max_length=100, blank=True)
    
    # Social Auth fields
    google_id = models.CharField(max_length=255, null=True, blank=True)
    apple_id = models.CharField(max_length=255, null=True, blank=True)
    is_phone_verified = models.BooleanField(default=False)
    phone_verification_code = models.CharField(max_length=6, null=True, blank=True)

    class Meta:
        db_table = 'users'
        swappable = 'AUTH_USER_MODEL'
