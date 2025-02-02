import pytest
from django.urls import reverse
from rest_framework import status
from datetime import timedelta
from django.utils import timezone
from rest_framework_simplejwt.tokens import AccessToken, RefreshToken
from freezegun import freeze_time
import jwt
from django.conf import settings

pytestmark = pytest.mark.django_db

@pytest.fixture
def override_token_settings(settings):
    """Override token settings for testing"""
    settings.SIMPLE_JWT = {
        'ACCESS_TOKEN_LIFETIME': timedelta(seconds=1),
        'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
        'ROTATE_REFRESH_TOKENS': True,
        'BLACKLIST_AFTER_ROTATION': True,
        'ALGORITHM': 'HS256',
        'SIGNING_KEY': settings.SECRET_KEY,
        'AUTH_HEADER_TYPES': ('Bearer',),
        'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    }
    return settings

def create_token_with_exp(user, exp_time):
    """Create a token with specific expiration time"""
    token = AccessToken()
    token.set_exp(lifetime=timedelta(seconds=0))  # Set initial lifetime
    token.payload['user_id'] = user.id
    token.payload['exp'] = int(exp_time.timestamp())  # Override with our expiration
    token.payload['token_type'] = 'access'
    token.payload['jti'] = token.payload['jti']  # Preserve the JTI
    return str(token)

def test_access_token_expiration(api_client, test_user, override_token_settings):
    """Test that access token expires after specified time"""
    start_time = timezone.now()
    
    # Create token that expires in 1 second
    token = create_token_with_exp(test_user, start_time + timedelta(seconds=1))
    
    # Verify token works initially
    protected_url = reverse('users:protected-endpoint')
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    
    with freeze_time(start_time):
        initial_response = api_client.get(protected_url)
        assert initial_response.status_code == status.HTTP_200_OK

    # Move time forward past token expiration
    with freeze_time(start_time + timedelta(seconds=2)):
        response = api_client.get(protected_url)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

def test_refresh_token_still_valid_after_access_expires(api_client, test_user, override_token_settings):
    """Test that refresh token works after access token expires"""
    start_time = timezone.now()
    
    # Create tokens with specific expiration times
    access_token = create_token_with_exp(test_user, start_time + timedelta(seconds=1))
    
    # Create refresh token
    refresh = RefreshToken()
    refresh.set_exp(lifetime=timedelta(days=1))
    refresh.payload['user_id'] = test_user.id
    refresh_token = str(refresh)
    
    # Verify initial access works
    protected_url = reverse('users:protected-endpoint')
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
    
    with freeze_time(start_time):
        assert api_client.get(protected_url).status_code == status.HTTP_200_OK

    # Move time forward past access token expiration
    with freeze_time(start_time + timedelta(seconds=2)):
        # Verify old access token no longer works
        assert api_client.get(protected_url).status_code == status.HTTP_401_UNAUTHORIZED
        
        # Get new access token using refresh token
        refresh_url = reverse('users:token-refresh')
        refresh_response = api_client.post(
            refresh_url, 
            {'refresh': refresh_token}, 
            format='json'
        )
        assert refresh_response.status_code == status.HTTP_200_OK
        assert 'access' in refresh_response.data

        # Verify new access token works
        new_token = refresh_response.data['access']
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {new_token}')
        response = api_client.get(protected_url)
        assert response.status_code == status.HTTP_200_OK 