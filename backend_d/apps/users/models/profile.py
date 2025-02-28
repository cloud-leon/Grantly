from django.db import models
from django.conf import settings
from django.contrib.postgres.fields import ArrayField
from django.db.models.signals import post_save
from django.dispatch import receiver
from datetime import datetime

class UserProfile(models.Model):
    USER_TYPE_CHOICES = [
        ('student', 'Student'),
        ('mentor', 'Mentor'),
        ('admin', 'Admin')
    ]
    
    GENDER_CHOICES = [
        ('Male', 'Male'),
        ('Female', 'Female'),
        ('Other', 'Other'),
        ('Prefer not to say', 'Prefer not to say')
    ]
    
    RACE_CHOICES = [
        ('White/Caucasian', 'White/Caucasian'),
        ('Black/African American', 'Black/African American'),
        ('Asian', 'Asian'),
        ('Hispanic', 'Hispanic'),
        ('Native American / Pacific Islander', 'Native American / Pacific Islander'),
        ('Two or more races', 'Two or more races'),
        ('Other', 'Other'),
        ('Prefer not to say', 'Prefer not to say')
    ]
    
    YES_NO_PREFER_NOT_CHOICES = [
        ('Yes', 'Yes'),
        ('No', 'No'),
        ('Prefer not to say', 'Prefer not to say')
    ]
    
    YES_NO_DONT_KNOW_CHOICES = [
        ('Yes', 'Yes'),
        ('No', 'No'),
        ('I don\'t know', 'I don\'t know'),
        ('Prefer not to say', 'Prefer not to say')
    ]
    
    CITIZENSHIP_CHOICES = [
        ('US Citizen', 'US Citizen'),
        ('US Permanent Resident', 'US Permanent Resident'),
        ('International', 'International'),
        ('Other', 'Other')
    ]

    EDUCATION_LEVEL_CHOICES = [
        ('undergraduate', 'Undergraduate'),
        ('graduate', 'Graduate'),
        ('high_school', 'High School')
    ]

    # Base Fields
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='profile')
    firebase_uid = models.CharField(max_length=128, unique=True, null=True, blank=True)
    first_name = models.CharField(max_length=100, null=True, blank=True)
    last_name = models.CharField(max_length=100, null=True, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    bio = models.TextField(null=True, blank=True)
    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES, default='student')
    interests = models.JSONField(default=list, null=True, blank=True)
    education = models.JSONField(default=dict, null=True, blank=True)
    skills = models.JSONField(default=list, null=True, blank=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    
    # Contact Information
    email = models.EmailField(unique=True, null=True, blank=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    
    # Demographics
    gender = models.CharField(max_length=20, choices=GENDER_CHOICES, null=True, blank=True)
    race = models.CharField(max_length=50, choices=RACE_CHOICES, null=True, blank=True)
    disabilities = models.CharField(max_length=20, choices=YES_NO_PREFER_NOT_CHOICES, null=True, blank=True)
    military = models.CharField(max_length=20, choices=YES_NO_PREFER_NOT_CHOICES, null=True, blank=True)
    
    # Education Information
    grade_level = models.CharField(max_length=100, null=True, blank=True)
    financial_aid = models.CharField(max_length=20, choices=YES_NO_DONT_KNOW_CHOICES, null=True, blank=True)
    first_gen = models.CharField(max_length=20, choices=YES_NO_DONT_KNOW_CHOICES, null=True, blank=True)
    
    # Citizenship
    citizenship = models.CharField(max_length=30, choices=CITIZENSHIP_CHOICES, null=True, blank=True)
    
    # Education & Career Goals
    field_of_study = models.CharField(max_length=255, null=True, blank=True)
    career_goals = models.TextField(null=True, blank=True)
    
    # Education Level
    education_level = models.CharField(
        max_length=20, 
        choices=EDUCATION_LEVEL_CHOICES,
        null=True, 
        blank=True
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'user_profiles'
        
    def __str__(self):
        return f"{self.first_name} {self.last_name}'s Profile"

    def get_formatted_grade_level(self):
        """Returns grade level with current graduation year"""
        current_year = datetime.now().year
        base_level = self.grade_level.split('(')[0].strip()
        
        grad_year = None
        if 'High School Freshman' in base_level:
            grad_year = current_year + 3
        elif 'High School Sophomore' in base_level:
            grad_year = current_year + 2
        elif 'High School Junior' in base_level:
            grad_year = current_year + 1
        elif 'High School Senior' in base_level:
            grad_year = current_year
        elif 'College Freshman' in base_level:
            grad_year = current_year + 4
        elif 'College Sophomore' in base_level:
            grad_year = current_year + 3
        elif 'College Junior' in base_level:
            grad_year = current_year + 2
        elif 'College Senior' in base_level:
            grad_year = current_year + 1
            
        if grad_year:
            return f"{base_level} (Class of {grad_year})"
        return self.grade_level

# Signal to create profile when user is created
@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()