from django.contrib.auth.models import AbstractUser
from django.db import models
from django.core.validators import RegexValidator

class User(AbstractUser):
    phone_regex = RegexValidator(
        regex=r'^\+?1?\d{9,15}$',
        message="Phone number must be entered in the format: '+999999999'. Up to 15 digits allowed."
    )
    phone_number = models.CharField(validators=[phone_regex], max_length=15, unique=True, null=True, blank=True)
    is_phone_verified = models.BooleanField(default=False)
    firebase_uid = models.CharField(max_length=128, unique=True)
    
    # We don't need to store tokens since Firebase handles auth
    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = ['username']  # username is still required by Django

    class Meta:
        db_table = 'users'

    def __str__(self):
        return self.username or self.firebase_uid

    @property
    def full_name(self):
        if hasattr(self, 'profile'):
            return f"{self.profile.first_name} {self.profile.last_name}"
        return self.username

    def save(self, *args, **kwargs):
        if not self.username and self.email:
            self.username = self.email.split('@')[0]
        super().save(*args, **kwargs) 