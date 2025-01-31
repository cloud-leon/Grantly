from django.db import models

class UserProfile(models.Model):
    """User profile information"""
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
    interests = models.JSONField(default=list, blank=True)
    education = models.JSONField(default=dict, blank=True)
    skills = models.JSONField(default=list, blank=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    location = models.CharField(max_length=100, blank=True)

    class Meta:
        abstract = True 