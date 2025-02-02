import pytest
from django.urls import reverse
from rest_framework import status
from datetime import timedelta
from django.utils import timezone
from rest_framework_simplejwt.tokens import RefreshToken

pytestmark = pytest.mark.django_db

class TestTokenRefresh:
    def test_refresh_success(self, api_client, test_user):
        """Test successful token refresh"""
        # Get initial tokens
        login_url = reverse('users:login')
        login_data = {
            'username': test_user.username,
            'password': 'testpass123'
        }
        response = api_client.post(login_url, login_data, format='json')
        
        # Refresh token
        refresh_url = reverse('users:token-refresh')
        refresh_data = {
            'refresh': response.data['refresh']
        }
        refresh_response = api_client.post(refresh_url, refresh_data, format='json')
        
        assert refresh_response.status_code == status.HTTP_200_OK
        assert 'access' in refresh_response.data
        assert refresh_response.data['access'] != response.data['access']

    def test_refresh_invalid_token(self, api_client):
        """Test refresh with invalid token"""
        url = reverse('users:token-refresh')
        response = api_client.post(url, {'refresh': 'invalid-token'}, format='json')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_refresh_expired_token(self, api_client, test_user):
        """Test refresh with expired token"""
        # Create expired token
        refresh = RefreshToken.for_user(test_user)
        refresh.set_exp(lifetime=-timedelta(days=1))
        
        url = reverse('users:token-refresh')
        response = api_client.post(url, {'refresh': str(refresh)}, format='json')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_token_blacklist_after_refresh(self, api_client, test_user):
        """Test that old refresh tokens are blacklisted after refresh"""
        # Get initial tokens
        login_url = reverse('users:login')
        login_data = {
            'username': test_user.username,
            'password': 'testpass123'
        }
        response = api_client.post(login_url, login_data, format='json')
        old_refresh_token = response.data['refresh']
        
        # Refresh token
        refresh_url = reverse('users:token-refresh')
        refresh_response = api_client.post(
            refresh_url, 
            {'refresh': old_refresh_token}, 
            format='json'
        )
        
        # Try to use old refresh token again
        response = api_client.post(
            refresh_url, 
            {'refresh': old_refresh_token}, 
            format='json'
        )
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_access_with_refreshed_token(self, api_client, test_user):
        """Test accessing protected endpoint with refreshed token"""
        # Get initial tokens
        login_url = reverse('users:login')
        login_response = api_client.post(
            login_url, 
            {
                'username': test_user.username,
                'password': 'testpass123'
            }, 
            format='json'
        )
        
        # Get new access token
        refresh_url = reverse('users:token-refresh')
        refresh_response = api_client.post(
            refresh_url,
            {'refresh': login_response.data['refresh']},
            format='json'
        )
        new_access_token = refresh_response.data['access']
        
        # Access protected endpoint
        protected_url = reverse('users:protected-endpoint')
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {new_access_token}')
        response = api_client.get(protected_url)
        assert response.status_code == status.HTTP_200_OK 