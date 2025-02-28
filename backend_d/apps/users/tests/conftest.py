import pytest
from rest_framework.test import APIClient
from apps.users.models import User, UserProfile
from django.core import mail

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def test_user(db):
    user = User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123'
    )
    profile = UserProfile.objects.get(user=user)
    profile.interests = ['Programming', 'AI']
    profile.education = {
        'level': 'undergraduate',
        'field': 'Computer Science'
    }
    profile.education_level = 'undergraduate'
    profile.skills = ['Python', 'Django']
    profile.save()
    return user

@pytest.fixture(autouse=True)
def email_outbox():
    """Clear the email outbox before each test"""
    mail.outbox = []

@pytest.fixture
def auth_client(api_client, test_user):
    """Returns an authenticated API client"""
    api_client.force_authenticate(user=test_user)
    return api_client 