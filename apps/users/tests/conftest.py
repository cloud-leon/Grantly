import pytest
from rest_framework.test import APIClient
from apps.users.models import User
from django.core import mail

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def test_user():
    user = User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123'
    )
    return user

@pytest.fixture(autouse=True)
def email_outbox():
    """Clear the email outbox before each test"""
    mail.outbox = [] 