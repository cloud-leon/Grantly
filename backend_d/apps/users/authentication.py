from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from rest_framework_simplejwt.tokens import AccessToken
from django.utils import timezone
from datetime import datetime
from rest_framework.authentication import get_authorization_header, BaseAuthentication
from rest_framework import exceptions
from rest_framework_simplejwt.settings import api_settings
from firebase_admin import auth
from django.contrib.auth import get_user_model
from .models import User, UserProfile
from django.core.cache import cache

class CustomJWTAuthentication(JWTAuthentication):
    def get_validated_token(self, raw_token):
        """
        Validates a JWT token and returns a validated token.
        """
        try:
            token = AccessToken(raw_token)
            # Get current time in UTC
            now = timezone.now().timestamp()
            
            # Check if token has expired
            if token['exp'] <= now:
                raise exceptions.AuthenticationFailed('Token has expired')
                
            return token
        except TokenError as e:
            raise InvalidToken(str(e))

    def authenticate(self, request):
        header = get_authorization_header(request).decode('utf-8')
        if not header:
            return None

        try:
            parts = header.split()
            if len(parts) != 2 or parts[0].lower() != 'bearer':
                raise exceptions.AuthenticationFailed('Invalid token header')
            
            token = self.get_validated_token(parts[1])
            user = self.get_user(token)
            return (user, token)
            
        except (InvalidToken, TokenError) as e:
            raise exceptions.AuthenticationFailed(str(e))

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        if not auth_header:
            return None

        try:
            # Extract the token
            id_token = auth_header.split(' ').pop()
            # Verify the token
            decoded_token = auth.verify_id_token(id_token)
            
            # Get the user's firebase UID
            firebase_uid = decoded_token['uid']
            
            print(f"Authenticated Firebase UID: {firebase_uid}")  # Debug log
            
            # Try to get existing user
            try:
                user = User.objects.get(firebase_uid=firebase_uid)
            except User.DoesNotExist:
                # Create new user if doesn't exist
                user = User.objects.create(
                    username=decoded_token.get('phone_number', firebase_uid),
                    firebase_uid=firebase_uid,
                    phone_number=decoded_token.get('phone_number', ''),
                    is_phone_verified=True
                )
                print(f"Created new user with firebase_uid: {firebase_uid}")

            return (user, None)

        except Exception as e:
            print(f"Authentication error: {str(e)}")
            raise exceptions.AuthenticationFailed(str(e)) 