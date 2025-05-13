import pytest
from django.urls import reverse
from rest_framework import status
from apps.users.models import User, UserProfile
from rest_framework.test import APIClient

pytestmark = pytest.mark.django_db

def clean_up():
    User.objects.all().delete()
    UserProfile.objects.all().delete()

def test_user_registration_success(api_client):
    """Test successful user registration"""
    clean_up()
    data = {
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'testpass123',
        'firebase_uid': 'test123',
        'phone_number': '+1234567890'
    }
    
    response = api_client.post(
        reverse('users:register'),
        data,
        format='json'
    )
    assert response.status_code == 201
    
    user = User.objects.get(username='testuser')
    assert user.email == 'test@example.com'

def test_user_login_success(api_client, test_user):
    """Test successful login"""
    # Create test user first
    User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123',
        firebase_uid='test123',
        phone_number='+1234567890'
    )

    url = reverse('users:login')
    data = {
        'username': 'testuser',  # Use username instead of email
        'password': 'testpass123'
    }
    response = api_client.post(url, data, format='json')
    assert response.status_code == 200
    assert 'access' in response.data
    assert 'refresh' in response.data

def test_protected_endpoint_with_token(auth_client):
    """Test accessing protected endpoint with token"""
    url = reverse('users:protected-endpoint')
    response = auth_client.get(url, format='json')
    assert response.status_code == 200

def test_protected_endpoint_without_token(api_client):
    """Test accessing protected endpoint without token"""
    clean_up()
    url = reverse('users:protected-endpoint')
    response = api_client.get(url, format='json')
    assert response.status_code == status.HTTP_401_UNAUTHORIZED 