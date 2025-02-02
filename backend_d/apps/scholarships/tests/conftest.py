import pytest
from django.utils import timezone
from datetime import timedelta
from apps.scholarships.models import Scholarship, ScholarshipTag
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def scholarship_tag():
    return ScholarshipTag.objects.create(
        name='Engineering',
        description='Engineering scholarships'
    )

@pytest.fixture
def active_scholarship(scholarship_tag):
    scholarship = Scholarship.objects.create(
        title='Test Scholarship',
        description='Test Description',
        amount=5000.00,
        deadline=timezone.now().date() + timedelta(days=30),
        eligibility_criteria='Test Criteria',
        is_active=True
    )
    scholarship.tags.add(scholarship_tag)
    return scholarship

@pytest.fixture
def expired_scholarship(scholarship_tag):
    scholarship = Scholarship.objects.create(
        title='Expired Scholarship',
        description='Expired Description',
        amount=3000.00,
        deadline=timezone.now().date() - timedelta(days=1),
        eligibility_criteria='Test Criteria',
        is_active=True
    )
    scholarship.tags.add(scholarship_tag)
    return scholarship

@pytest.fixture
def auth_client(api_client, test_user):
    """Returns an authenticated API client"""
    refresh = RefreshToken.for_user(test_user)
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {str(refresh.access_token)}')
    return api_client

@pytest.fixture
def test_user(django_user_model):
    return django_user_model.objects.create_user(
        username='testuser',
        password='testpass123'
    ) 