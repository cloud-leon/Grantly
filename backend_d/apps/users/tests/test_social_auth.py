import pytest
from django.urls import reverse
from rest_framework import status
import jwt
import json
import requests
from unittest.mock import patch, MagicMock
from django.contrib.auth import get_user_model
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from firebase_admin import auth as firebase_auth
from apps.users.models import User

User = get_user_model()
pytestmark = pytest.mark.django_db

@pytest.fixture
def mock_private_key():
    # Generate a test private key
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048
    )
    return private_key

@pytest.fixture
def mock_public_key(mock_private_key):
    return mock_private_key.public_key()

@pytest.fixture
def apple_auth_url():
    return reverse('users_auth:apple-auth')

@pytest.fixture
def mock_apple_public_keys(mock_public_key):
    # Convert public key to JWK format
    public_numbers = mock_public_key.public_numbers()
    return {
        'keys': [{
            'kty': 'RSA',
            'kid': 'test_key_id',
            'n': str(public_numbers.n),
            'e': str(public_numbers.e),
        }]
    }

@pytest.fixture
def mock_apple_id_token():
    return 'valid.mock.token'

@pytest.mark.django_db
class TestAppleAuth:
    @pytest.fixture(autouse=True)
    def setup(self, api_client):
        self.client = api_client
        self.url = reverse('users:apple-auth')

    def test_apple_auth_missing_token(self):
        response = self.client.post(self.url, {}, format='json')
        assert response.status_code == 400

    @patch('firebase_admin.auth.verify_id_token')
    def test_apple_auth_success(self, mock_verify_token):
        # Mock Firebase token verification with complete data
        mock_verify_token.return_value = {
            'uid': 'apple123',
            'email': 'apple@example.com',
            'name': 'Apple User',
            'email_verified': True,
            'firebase': {
                'sign_in_provider': 'apple.com',
                'identities': {
                    'apple.com': ['apple123'],
                    'email': ['apple@example.com']
                }
            },
            'phone_number': '+1234567890'  # Add phone number
        }

        data = {'id_token': 'valid.apple.token'}
        response = self.client.post(self.url, data, format='json')
        
        assert response.status_code == 200
        user = User.objects.get(firebase_uid='apple123')
        assert user.email == 'apple@example.com'

    @patch('firebase_admin.auth.verify_id_token')
    def test_apple_auth_existing_user(self, mock_verify_token):
        # Create existing user with all required fields
        existing_user = User.objects.create_user(
            username='appleuser',
            email='apple@example.com',
            password='testpass123',
            firebase_uid='apple123',
            phone_number='+1234567890'
        )

        # Mock Firebase verification with complete data
        mock_verify_token.return_value = {
            'uid': 'apple123',
            'email': 'apple@example.com',
            'name': 'Apple User',
            'email_verified': True,
            'firebase': {
                'sign_in_provider': 'apple.com',
                'identities': {
                    'apple.com': ['apple123'],
                    'email': ['apple@example.com']
                }
            },
            'phone_number': '+1234567890'
        }

        data = {'id_token': 'valid.apple.token'}
        response = self.client.post(self.url, data, format='json')
        
        assert response.status_code == 200
        assert User.objects.count() == 1
        assert User.objects.first() == existing_user

class TestGoogleAuth:
    @pytest.fixture(autouse=True)
    def setup(self, api_client):
        self.client = api_client
        self.url = reverse('users:google-auth')

    def test_google_auth_missing_token(self):
        response = self.client.post(self.url, {}, format='json')
        assert response.status_code == 400

    @patch('firebase_admin.auth.verify_id_token')
    def test_google_auth_success(self, mock_verify_token):
        # Mock Firebase token verification with complete data
        mock_verify_token.return_value = {
            'uid': 'test123',
            'email': 'test@example.com',
            'name': 'Test User',
            'email_verified': True,
            'firebase': {
                'sign_in_provider': 'google.com',
                'identities': {
                    'google.com': ['test123'],
                    'email': ['test@example.com']
                }
            },
            'phone_number': '+1234567890'
        }

        data = {'token': 'valid.google.token'}
        response = self.client.post(self.url, data, format='json')
        
        assert response.status_code == 200
        user = User.objects.get(firebase_uid='test123')
        assert user.email == 'test@example.com'

    @patch('firebase_admin.auth.verify_id_token')
    def test_google_auth_existing_user(self, mock_verify_token):
        # Create existing user with all required fields
        existing_user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            firebase_uid='test123',
            phone_number='+1234567890'
        )

        # Mock Firebase verification with complete data
        mock_verify_token.return_value = {
            'uid': 'test123',
            'email': 'test@example.com',
            'name': 'Test User',
            'email_verified': True,
            'firebase': {
                'sign_in_provider': 'google.com',
                'identities': {
                    'google.com': ['test123'],
                    'email': ['test@example.com']
                }
            },
            'phone_number': '+1234567890'
        }

        data = {'token': 'valid.google.token'}
        response = self.client.post(self.url, data, format='json')
        
        assert response.status_code == 200
        assert User.objects.count() == 1
        assert User.objects.first() == existing_user

    def test_google_auth_invalid_token(self):
        data = {'token': 'invalid.token'}
        response = self.client.post(self.url, data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST