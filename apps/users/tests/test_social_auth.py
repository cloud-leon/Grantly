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
    return reverse('users:apple-auth')

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

class TestAppleAuth:
    def test_apple_auth_missing_token(self, api_client, apple_auth_url):
        """Test Apple auth fails when no token provided"""
        response = api_client.post(apple_auth_url, {}, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'Either \'code\' or \'id_token\' must be provided' in str(response.data)

    @patch('apps.users.serializers.jwt.get_unverified_header')
    @patch('apps.users.serializers.requests.get')
    @patch('apps.users.serializers.jwt.decode')
    def test_apple_auth_success(self, mock_jwt_decode, mock_get, mock_header, 
                               api_client, apple_auth_url):
        """Test successful Apple authentication"""
        # Mock JWT header
        mock_header.return_value = {'kid': 'test_key_id'}
        
        # Mock Apple's public keys response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'keys': [{
                'kid': 'test_key_id',
                'kty': 'RSA',
                'n': 'test_n',
                'e': 'test_e'
            }]
        }
        mock_get.return_value = mock_response

        # Mock JWT decode result
        mock_jwt_decode.return_value = {
            'sub': 'test.apple.user.id',
            'email': 'test@example.com',
            'aud': 'com.ephriamlabs.grantly',
            'iss': 'https://appleid.apple.com',
        }

        # Test data
        data = {
            'id_token': 'valid.mock.token',
            'user': {
                'name': {'firstName': 'Test', 'lastName': 'User'},
                'email': 'test@example.com'
            }
        }

        response = api_client.post(apple_auth_url, data, format='json')
        
        if response.status_code != status.HTTP_200_OK:
            print("Response data:", response.data)  # For debugging
            
        assert response.status_code == status.HTTP_200_OK
        assert 'access' in response.data
        assert 'refresh' in response.data

        # Verify user was created
        user = User.objects.get(apple_id='test.apple.user.id')
        assert user.email == 'test@example.com'
        assert user.first_name == 'Test'
        assert user.last_name == 'User'

    @patch('apps.users.serializers.jwt.get_unverified_header')
    @patch('apps.users.serializers.requests.get')
    def test_apple_auth_invalid_token(self, mock_get, mock_header,
                                    api_client, apple_auth_url):
        """Test Apple auth fails with invalid token"""
        # Mock JWT header
        mock_header.return_value = {'kid': 'test_key_id'}
        
        # Mock Apple's public keys response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'keys': [{
                'kid': 'test_key_id',
                'kty': 'RSA',
                'n': 'test_n',
                'e': 'test_e'
            }]
        }
        mock_get.return_value = mock_response

        data = {
            'id_token': 'invalid.token.here',
        }

        response = api_client.post(apple_auth_url, data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'Invalid Apple token' in str(response.data)

    @patch('apps.users.serializers.jwt.get_unverified_header')
    @patch('apps.users.serializers.requests.get')
    @patch('apps.users.serializers.jwt.decode')
    def test_apple_auth_existing_user(self, mock_jwt_decode, mock_get, mock_header,
                                    api_client, apple_auth_url):
        """Test Apple auth with existing user"""
        # Create a user first
        existing_user = User.objects.create_user(
            username='existing_user',
            email='test@example.com',
            apple_id='test.apple.user.id'
        )

        # Mock JWT header
        mock_header.return_value = {'kid': 'test_key_id'}
        
        # Mock Apple's public keys response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'keys': [{
                'kid': 'test_key_id',
                'kty': 'RSA',
                'n': 'test_n',
                'e': 'test_e'
            }]
        }
        mock_get.return_value = mock_response

        # Mock JWT decode result
        mock_jwt_decode.return_value = {
            'sub': 'test.apple.user.id',
            'email': 'test@example.com',
            'aud': 'com.ephriamlabs.grantly',
            'iss': 'https://appleid.apple.com',
        }

        data = {
            'id_token': 'valid.mock.token',
        }

        response = api_client.post(apple_auth_url, data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        assert 'access' in response.data
        assert 'refresh' in response.data

        # Verify no new user was created
        assert User.objects.count() == 1
        assert User.objects.first() == existing_user

class TestGoogleAuth:
    @pytest.fixture
    def google_auth_url(self):
        return reverse('users:google-auth')

    def test_google_auth_missing_token(self, api_client, google_auth_url):
        """Test Google auth fails when no token provided"""
        response = api_client.post(google_auth_url, {}, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    @patch('apps.users.serializers.id_token.verify_oauth2_token')
    def test_google_auth_success(self, mock_verify_token, api_client, google_auth_url):
        """Test successful Google authentication"""
        # Mock the token verification
        mock_verify_token.return_value = {
            'sub': 'test.google.user.id',
            'email': 'test@example.com',
            'given_name': 'Test',
            'family_name': 'User',
            'iss': 'accounts.google.com'
        }

        data = {
            'token': 'valid.google.token'
        }

        response = api_client.post(google_auth_url, data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        assert 'access' in response.data
        assert 'refresh' in response.data

        # Verify user was created
        user = User.objects.get(google_id='test.google.user.id')
        assert user.email == 'test@example.com'
        assert user.first_name == 'Test'
        assert user.last_name == 'User'

    @patch('apps.users.serializers.id_token.verify_oauth2_token')
    def test_google_auth_existing_user(self, mock_verify_token, api_client, google_auth_url):
        """Test Google auth with existing user"""
        # Create a user first
        existing_user = User.objects.create_user(
            username='existing_user',
            email='test@example.com',
            google_id='test.google.user.id'
        )

        # Mock the token verification
        mock_verify_token.return_value = {
            'sub': 'test.google.user.id',
            'email': 'test@example.com',
            'iss': 'accounts.google.com'
        }

        data = {
            'token': 'valid.google.token'
        }

        response = api_client.post(google_auth_url, data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        assert 'access' in response.data
        assert 'refresh' in response.data

        # Verify no new user was created
        assert User.objects.count() == 1
        assert User.objects.first() == existing_user