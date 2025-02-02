from django.db import models

class SocialAuthUser(models.Model):
    """Social authentication fields"""
    google_id = models.CharField(max_length=150, unique=True, null=True, blank=True)
    apple_id = models.CharField(max_length=150, unique=True, null=True, blank=True)

    class Meta:
        abstract = True 