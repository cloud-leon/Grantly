from django.contrib.auth.models import AbstractUser
from django.db import models
from .auth import PhoneAuthUser
from .social_auth import SocialAuthUser

class User(AbstractUser, PhoneAuthUser, SocialAuthUser):
    """
    Combined user model with all functionality:
    - Base user authentication (AbstractUser)
    - Phone authentication (PhoneAuthUser)
    - Social authentication (SocialAuthUser)
    """
    
    class Meta:
        db_table = 'users'
        
    def __str__(self):
        return self.username
        
    @property
    def full_name(self):
        if hasattr(self, 'profile'):
            return f"{self.profile.first_name} {self.profile.last_name}"
        return self.username 