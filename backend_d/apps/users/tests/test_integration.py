import pytest
from django.urls import reverse
from rest_framework import status
from apps.users.models import User, UserProfile
from rest_framework.test import APIClient

pytestmark = pytest.mark.django_db  # Apply database mark to all tests in module
def cleanup():
    """Clean up test data"""
    User.objects.all().delete()
    UserProfile.objects.all().delete()

@pytest.mark.django_db
def test_complete_auth_flow(api_client):
    """Test complete authentication flow"""
    cleanup()
    
    # Registration
    register_data = {
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'testpass123',
        'firebase_uid': 'test123',
        'first_name': 'Test',
        'last_name': 'User',
        'phone_number': '+1234567890'
    }
    response = api_client.post(
        reverse('users:register'),
        register_data,
        format='json'
    )
    assert response.status_code == 201

def test_failed_auth_flow_scenarios(api_client):
    """Test various failure scenarios"""
    # Test registration with invalid data
    invalid_data = {
        'email': 'invalid-email',
        'password': '123'  # Too short
    }
    response = api_client.post(
        reverse('users:register'),
        invalid_data,
        format='json'
    )
    assert response.status_code == 400

def test_user_creation_and_query():
    """Test user creation and database queries"""
    # Create test user
    test_user = User.objects.create_user(
        username='dbuser',
        password='TestPass123!',
        email='db@example.com'
    )
    
    # Test direct database queries
    queried_user = User.objects.get(username='dbuser')
    assert queried_user.email == 'db@example.com'
    
    # Test user password hashing
    assert queried_user.check_password('TestPass123!') 