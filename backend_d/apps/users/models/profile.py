from django.db import models
from django.conf import settings
from django.contrib.postgres.fields import ArrayField
from django.db.models.signals import post_save
from django.dispatch import receiver
from datetime import datetime
from phonenumber_field.modelfields import PhoneNumberField

# Add a custom manager for UserProfile
class UserProfileManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().select_related('user')

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
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='profile',
    )
    firebase_uid = models.CharField(
        max_length=128,
        unique=True,
        null=False,
        blank=False,
        db_index=True,
    )
    first_name = models.CharField(max_length=100, blank=True)
    last_name = models.CharField(max_length=100, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    bio = models.TextField(null=True, blank=True)
    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES, default='student')
    interests = models.JSONField(default=list, null=True, blank=True)
    education = models.JSONField(default=dict, null=True, blank=True)
    skills = models.JSONField(default=list, null=True, blank=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    
    # Contact Information
    email = models.EmailField(blank=True)
    phone_number = PhoneNumberField(blank=True)
    
    # Demographics
    gender = models.CharField(max_length=50, blank=True)
    race = models.CharField(max_length=100, blank=True)
    disabilities = models.CharField(
        max_length=20,
        choices=YES_NO_PREFER_NOT_CHOICES,
        default='No',
        blank=True
    )
    military = models.CharField(
        max_length=20,
        choices=YES_NO_PREFER_NOT_CHOICES,
        default='No',
        blank=True
    )
    
    # Education Information
    grade_level = models.CharField(max_length=50, blank=True)
    financial_aid = models.CharField(
        max_length=20,
        choices=YES_NO_PREFER_NOT_CHOICES,
        default='No',
        blank=True
    )
    first_gen = models.CharField(
        max_length=20,
        choices=YES_NO_PREFER_NOT_CHOICES,
        default='No',
        blank=True
    )
    
    # Citizenship
    citizenship = models.CharField(max_length=100, blank=True)
    
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
    
    # Credits
    credits = models.IntegerField(default=3)

    # Additional fields
    location = models.CharField(max_length=200, blank=True)
    hear_about_us = models.CharField(max_length=100, blank=True)
    referral_code = models.CharField(max_length=50, blank=True)

    # Add the custom manager
    objects = UserProfileManager()

    class Meta:
        db_table = 'user_profiles'
        indexes = [
            models.Index(fields=['firebase_uid']),
            models.Index(fields=['email']),
            models.Index(fields=['created_at']),
            models.Index(fields=['user']),
        ]
        
    def __str__(self):
        return f"{self.first_name} {self.last_name}"

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

    @property
    def is_complete(self):
        required_fields = [
            'first_name', 'last_name', 'email', 'phone_number',
            'date_of_birth', 'gender', 'citizenship', 'race',
            'grade_level'
        ]
        return all(getattr(self, field) for field in required_fields)

    def save(self, *args, **kwargs):
        if not self.firebase_uid and self.user:
            self.firebase_uid = self.user.firebase_uid
        super().save(*args, **kwargs)

# Signal to create profile when user is created
@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()