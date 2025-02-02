import pytest
from django.urls import reverse
from rest_framework import status
from apps.users.models import User

pytestmark = pytest.mark.django_db

def test_user_registration_success(api_client):
    """Test successful user registration"""
    url = reverse('users:register')
    data = {
        'username': 'newuser',
        'email': 'newuser@example.com',
        'password': 'testpass123',
        'password2': 'testpass123'
    }
    response = api_client.post(url, data, format='json')
    assert response.status_code == status.HTTP_201_CREATED
    assert User.objects.filter(username='newuser').exists()

def test_user_login_success(api_client, test_user):
    """Test successful login and token generation"""
    url = reverse('users:login')
    data = {
        'username': test_user.username,
        'password': 'testpass123'
    }
    response = api_client.post(url, data, format='json')
    assert response.status_code == status.HTTP_200_OK
    assert 'access' in response.data
    assert 'refresh' in response.data

def test_protected_endpoint_with_token(api_client, test_user):
    """Test accessing protected endpoint with valid token"""
    # First login to get token
    login_url = reverse('users:login')
    login_data = {
        'username': test_user.username,
        'password': 'testpass123'
    }
    login_response = api_client.post(login_url, login_data, format='json')
    token = login_response.data['access']

    # Access protected endpoint
    protected_url = reverse('users:protected-endpoint')
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    response = api_client.get(protected_url)
    assert response.status_code == status.HTTP_200_OK

def test_protected_endpoint_without_token(api_client):
    """Test accessing protected endpoint without token"""
    url = reverse('users:protected-endpoint')
    response = api_client.get(url)
    assert response.status_code == status.HTTP_401_UNAUTHORIZED 