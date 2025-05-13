import pytest
from django.urls import reverse
from rest_framework import status
from django.core import mail
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.contrib.auth.tokens import default_token_generator

pytestmark = pytest.mark.django_db

def test_password_reset_request_valid_email(api_client, test_user):
    """Test requesting password reset with valid email"""
    url = reverse('users:password-reset')
    response = api_client.post(
        url,
        {'email': test_user.email},
        format='json'
    )
    assert response.status_code == 200
    assert len(mail.outbox) == 1
    assert mail.outbox[0].to[0] == test_user.email
    assert 'Password Reset Request' in mail.outbox[0].subject

def test_password_reset_request_invalid_email(api_client):
    """Test requesting a password reset with invalid email"""
    url = reverse('users:password-reset')
    response = api_client.post(url, {'email': 'nonexistent@example.com'}, format='json')
    
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert len(mail.outbox) == 0

def test_password_reset_confirm_valid_token(api_client, test_user):
    """Test confirming a password reset with valid token"""
    # Generate token and uid
    uid = urlsafe_base64_encode(force_bytes(test_user.pk))
    token = default_token_generator.make_token(test_user)
    
    url = reverse('users:password-reset-confirm', kwargs={'uidb64': uid, 'token': token})
    new_password = 'newpassword123'
    
    data = {
        'password': new_password,
        'password2': new_password,
        'token': token,
        'uidb64': uid,
    }
    
    response = api_client.post(url, data, format='json')
    assert response.status_code == status.HTTP_200_OK
    
    # Verify the password was changed
    test_user.refresh_from_db()
    assert test_user.check_password(new_password)

def test_password_reset_confirm_invalid_token(api_client, test_user):
    """Test password reset with invalid token"""
    uid = urlsafe_base64_encode(force_bytes(test_user.pk))
    
    url = reverse('users:password-reset-confirm', kwargs={'uidb64': uid, 'token': 'invalid-token'})
    
    data = {
        'password': 'newpassword123',
        'password2': 'newpassword123',
        'token': 'invalid-token',
        'uidb64': uid,
    }
    
    response = api_client.post(url, data, format='json')
    assert response.status_code == status.HTTP_400_BAD_REQUEST

def test_password_reset_confirm_passwords_dont_match(api_client, test_user):
    """Test password reset with mismatched passwords"""
    uid = urlsafe_base64_encode(force_bytes(test_user.pk))
    token = default_token_generator.make_token(test_user)
    
    url = reverse('users:password-reset-confirm', kwargs={'uidb64': uid, 'token': token})
    
    data = {
        'password': 'newpassword123',
        'password2': 'differentpassword',
        'token': token,
        'uidb64': uid,
    }
    
    response = api_client.post(url, data, format='json')
    assert response.status_code == status.HTTP_400_BAD_REQUEST

def test_password_reset_confirm_invalid_uid(api_client):
    """Test password reset with invalid user id"""
    url = reverse('users:password-reset-confirm', kwargs={'uidb64': 'invalid', 'token': 'invalid-token'})
    
    data = {
        'password': 'newpass123',
        'token': 'invalid-token'
    }
    
    response = api_client.post(url, data, format='json')
    assert response.status_code == status.HTTP_400_BAD_REQUEST 