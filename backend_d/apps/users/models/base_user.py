from django.contrib.auth.models import AbstractUser
from django.db import models

class BaseUser(AbstractUser):
    """Base user model with authentication fields"""
    email = models.EmailField(unique=True)
    is_active = models.BooleanField(default=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    last_login = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True 