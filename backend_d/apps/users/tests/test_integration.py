import pytest
from django.urls import reverse
from rest_framework import status
from apps.users.models import User

pytestmark = pytest.mark.django_db  # Apply database mark to all tests in module

def test_complete_auth_flow(client):
    """Test the complete flow: register → login → access protected endpoint"""
    # Step 1: Register a new user
    register_url = reverse('users:register')
    register_data = {
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'SecurePass123!',
        'password2': 'SecurePass123!'
    }
    register_response = client.post(register_url, register_data, format='json')
    assert register_response.status_code == status.HTTP_201_CREATED

    # Step 2: Verify user exists in database
    user = User.objects.get(username='testuser')
    assert user is not None
    assert user.email == 'test@example.com'

    # Step 3: Login with new user
    login_url = reverse('users:login')
    login_data = {
        'username': 'testuser',
        'password': 'SecurePass123!'
    }
    login_response = client.post(login_url, login_data, format='json')
    assert login_response.status_code == status.HTTP_200_OK
    assert 'access' in login_response.data
    assert 'refresh' in login_response.data

    # Step 4: Access protected endpoint with token
    protected_url = reverse('users:protected-endpoint')
    token = login_response.data['access']  # Use access token
    protected_response = client.get(
        protected_url,
        HTTP_AUTHORIZATION=f'Bearer {token}'
    )
    assert protected_response.status_code == status.HTTP_200_OK

def test_failed_auth_flow_scenarios(client):
    """Test various failure scenarios in the authentication flow"""
    register_url = reverse('users:register')
    login_url = reverse('users:login')
    protected_url = reverse('users:protected-endpoint')

    # Test registration with existing username
    initial_user_data = {
        'username': 'existinguser',
        'password': 'SecurePass123!',
        'password2': 'SecurePass123!',  # Add password confirmation
        'email': 'existing@example.com'
    }
    client.post(register_url, initial_user_data, format='json')
    
    # Attempt to register same username
    duplicate_response = client.post(register_url, initial_user_data, format='json')
    assert duplicate_response.status_code == status.HTTP_400_BAD_REQUEST

    # Test login with wrong password
    wrong_password_data = {
        'username': 'existinguser',
        'password': 'WrongPass123!'
    }
    login_response = client.post(login_url, wrong_password_data, format='json')
    assert login_response.status_code == status.HTTP_401_UNAUTHORIZED

    # Test protected endpoint without token
    unauth_response = client.get(protected_url)
    assert unauth_response.status_code == status.HTTP_401_UNAUTHORIZED

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