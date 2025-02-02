from django.db import models
from phonenumber_field.modelfields import PhoneNumberField

class PhoneAuthUser(models.Model):
    """Phone authentication fields"""
    phone_number = PhoneNumberField(unique=True, null=True, blank=True)
    is_phone_verified = models.BooleanField(default=False)
    phone_verification_code = models.CharField(max_length=6, null=True, blank=True)

    class Meta:
        abstract = True 