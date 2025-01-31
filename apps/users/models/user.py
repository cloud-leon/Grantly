from django.db import models
from .base_user import BaseUser
from .profile import UserProfile
from .auth import PhoneAuthUser
from .social_auth import SocialAuthUser

class User(BaseUser, UserProfile, PhoneAuthUser, SocialAuthUser):
    """
    Combined user model with all functionality:
    - Base user authentication (BaseUser)
    - Profile information (UserProfile)
    - Phone authentication (PhoneAuthUser)
    - Social authentication (SocialAuthUser)
    """
    
    class Meta:
        db_table = 'users'
        swappable = 'AUTH_USER_MODEL'
        
    def __str__(self):
        return self.username 