import pytest
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model
from apps.users.models import UserProfile
from django.core import mail

User = get_user_model()

@pytest.fixture(autouse=True)
def disable_throttling(settings):
    """Disable throttling for all tests"""
    settings.REST_FRAMEWORK = {
        'DEFAULT_THROTTLE_CLASSES': [],
        'DEFAULT_THROTTLE_RATES': {},
        'DEFAULT_PERMISSION_CLASSES': [],
        'DEFAULT_AUTHENTICATION_CLASSES': [
            'rest_framework_simplejwt.authentication.JWTAuthentication',
        ],
        'TEST_REQUEST_DEFAULT_FORMAT': 'json'
    }
    # Remove throttling middleware
    settings.MIDDLEWARE = [
        m for m in settings.MIDDLEWARE
        if not m.endswith('throttling.RequestRateThrottleMiddleware')
    ]

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def test_user(db):
    # Clean up existing data
    User.objects.all().delete()
    UserProfile.objects.all().delete()
    
    # Create test user with all required fields
    user = User.objects.create_user(
        username='testuser',  # Add username
        email='test@example.com',
        password='testpass123',
        phone_number='+1234567890',  # Add phone number if required
        firebase_uid='test123',  # Add required field
        # Add any other required fields for your User model
    )
    
    # Create profile if not automatically created by signals
    UserProfile.objects.get_or_create(
        user=user,
        defaults={
            'phone_number': '+1234567890'
        }
    )
    return user

@pytest.fixture(autouse=True)
def email_outbox():
    """Clear the email outbox before each test"""
    mail.outbox = []

@pytest.fixture
def authenticated_client(api_client, test_user):
    api_client.force_authenticate(user=test_user)
    return api_client 