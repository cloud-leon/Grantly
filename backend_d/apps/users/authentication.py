from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from rest_framework_simplejwt.tokens import AccessToken
from django.utils import timezone
from datetime import datetime
from rest_framework.authentication import get_authorization_header
from rest_framework import exceptions
from rest_framework_simplejwt.settings import api_settings

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