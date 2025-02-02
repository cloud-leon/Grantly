import pytest
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from apps.scholarships.models import Scholarship, ScholarshipTag
from apps.applications.models import Application

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def test_user(django_user_model):
    return django_user_model.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123'
    )

@pytest.fixture
def auth_client(api_client, test_user):
    """Returns an authenticated API client"""
    api_client.force_authenticate(user=test_user)
    return api_client

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
def application(test_user, active_scholarship):
    return Application.objects.create(
        user=test_user,
        scholarship=active_scholarship,
        status='pending',
        swipe_status='right'
    ) 