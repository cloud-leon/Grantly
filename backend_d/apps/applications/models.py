from django.db import models
from django.conf import settings
from apps.scholarships.models import Scholarship

# Create your models here.

class Application(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('submitted', 'Submitted'),
        ('under_review', 'Under Review'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
        ('withdrawn', 'Withdrawn')
    ]

    SWIPE_CHOICES = [
        ('left', 'Not Interested'),
        ('right', 'Interested'),
        ('saved', 'Saved for Later')
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='applications'
    )
    scholarship = models.ForeignKey(
        Scholarship,
        on_delete=models.CASCADE,
        related_name='applications'
    )
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )
    swipe_status = models.CharField(
        max_length=10,
        choices=SWIPE_CHOICES,
        default='saved'
    )
    answers = models.JSONField(default=dict)  # Store application answers
    documents = models.JSONField(default=list)  # Store document URLs
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    submitted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        unique_together = ['user', 'scholarship']
        ordering = ['-updated_at']

    def __str__(self):
        return f"{self.user.username}'s application for {self.scholarship.title}"
