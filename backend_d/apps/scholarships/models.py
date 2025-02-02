from django.db import models
from django.utils.text import slugify

# Create your models here.

class Scholarship(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField()
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    deadline = models.DateField()
    eligibility_criteria = models.TextField()
    is_active = models.BooleanField(default=True)
    tags = models.ManyToManyField(
        'ScholarshipTag',
        related_name='scholarships'
    )
    education_level = models.CharField(max_length=50, blank=True)
    field_of_study = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        app_label = 'scholarships'
        ordering = ['-created_at']
        verbose_name = 'Scholarship'
        verbose_name_plural = 'Scholarships'

    def __str__(self):
        return self.title

    @property
    def is_expired(self):
        """Check if scholarship deadline has passed"""
        from django.utils import timezone
        return self.deadline < timezone.now().date()

    @classmethod
    def get_by_tag(cls, tag_slug):
        """Get all scholarships for a specific tag"""
        return cls.objects.filter(
            tags__slug=tag_slug,
            is_active=True
        ).select_related()

    @classmethod
    def get_active_tags(cls):
        """Get all tags that have active scholarships"""
        return ScholarshipTag.objects.filter(
            scholarships__is_active=True
        ).distinct()

class ScholarshipTag(models.Model):
    name = models.CharField(max_length=255, unique=True)
    slug = models.SlugField(max_length=255, unique=True, blank=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['name']
        verbose_name = 'Scholarship Tag'
        verbose_name_plural = 'Scholarship Tags'

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name
    
    def get_scholarships_count(self):
        """Get count of scholarships with this tag"""
        return self.scholarships.count()