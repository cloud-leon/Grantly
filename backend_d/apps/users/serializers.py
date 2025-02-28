from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from apps.users.models import UserProfile
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes
from django.core.mail import send_mail
from django.conf import settings
from phonenumber_field.serializerfields import PhoneNumberField
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import requests
import jwt
import random
from datetime import datetime, timedelta
import json
from phonenumber_field.phonenumber import PhoneNumber

User = get_user_model()

class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'user', 'firebase_uid', 'first_name', 'last_name', 'date_of_birth',
            'email', 'phone_number', 'gender', 'race', 'disabilities',
            'military', 'grade_level', 'financial_aid', 'first_gen',
            'citizenship', 'field_of_study', 'career_goals',
            'education_level', 'interests', 'education', 'skills', 'profile_picture',
            'bio', 'user_type'
        ]
        read_only_fields = ['user']

    def validate_interests(self, value):
        if not isinstance(value, list):
            raise serializers.ValidationError("Interests must be a list")
        return value

    def validate_education(self, value):
        if not isinstance(value, dict):
            raise serializers.ValidationError("Education must be a dictionary")
        return value

    def validate_skills(self, value):
        if not isinstance(value, list):
            raise serializers.ValidationError("Skills must be a list")
        return value

class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()  # Nested serializer for profile

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'profile']
        read_only_fields = ['id', 'username', 'email']

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile', {})
        if profile_data:
            profile_serializer = ProfileSerializer(
                instance.profile,
                data=profile_data,
                partial=True
            )
            profile_serializer.is_valid(raise_exception=True)
            profile_serializer.save()
        return instance

class UserRegistrationSerializer(serializers.ModelSerializer):
    password2 = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'password2')
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError("Passwords must match.")
        return data

    def create(self, validated_data):
        validated_data.pop('password2')
        user = User.objects.create_user(**validated_data)
        return user

class UserLoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = authenticate(**data)
        if user and user.is_active:
            refresh = RefreshToken.for_user(user)
            return {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }
        raise serializers.ValidationError("Incorrect Credentials")

class PasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        # Check if user exists with this email
        try:
            self.user = User.objects.get(email=value)
        except User.DoesNotExist:
            raise serializers.ValidationError("No user found with this email address.")
        return value

    def save(self):
        user = self.user
        # Generate token and uid
        token = default_token_generator.make_token(user)
        uid = urlsafe_base64_encode(force_bytes(user.pk))
        
        # Create reset link
        reset_url = f"{settings.FRONTEND_URL}/reset-password/{uid}/{token}/"
        
        # Send email
        send_mail(
            'Password Reset Request',
            f'Click the following link to reset your password: {reset_url}',
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )

class PasswordResetConfirmSerializer(serializers.Serializer):
    password = serializers.CharField(write_only=True)
    password2 = serializers.CharField(write_only=True)
    token = serializers.CharField()
    uidb64 = serializers.CharField()

    def validate(self, data):
        # First validate passwords match
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Passwords must match."})

        try:
            # Decode the uidb64 to get the user
            uid = urlsafe_base64_decode(data['uidb64']).decode()
            self.user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            raise serializers.ValidationError({"uidb64": "Invalid reset link"})

        # Validate the token
        if not default_token_generator.check_token(self.user, data['token']):
            raise serializers.ValidationError({"token": "Invalid or expired reset link"})

        return data

    def save(self):
        password = self.validated_data['password']
        self.user.set_password(password)
        self.user.save()
        return self.user

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'id', 'user', 'firebase_uid', 'first_name', 'last_name',
            'date_of_birth', 'bio', 'user_type', 'interests', 'education',
            'skills', 'profile_picture', 'gender', 'race', 'disabilities',
            'military', 'grade_level', 'financial_aid', 'first_gen',
            'citizenship', 'field_of_study', 'career_goals', 'education_level'
        ]
        read_only_fields = ['id', 'user']

    def validate_interests(self, value):
        if not isinstance(value, list):
            raise serializers.ValidationError("Interests must be a list")
        return value
        
    def validate_skills(self, value):
        if not isinstance(value, list):
            raise serializers.ValidationError("Skills must be a list")
        return value
        
    def validate_education(self, value):
        if not isinstance(value, dict):
            raise serializers.ValidationError("Education must be a dictionary")
        return value

    def validate_education_level(self, value):
        if value not in dict(UserProfile.EDUCATION_LEVEL_CHOICES).keys():
            raise serializers.ValidationError(
                f"Education level must be one of: {', '.join(dict(UserProfile.EDUCATION_LEVEL_CHOICES).keys())}"
            )
        return value

class GoogleAuthSerializer(serializers.Serializer):
    token = serializers.CharField()

    def validate_token(self, token):
        try:
            # Verify the token
            idinfo = id_token.verify_oauth2_token(
                token,
                google_requests.Request(),
                settings.GOOGLE_CLIENT_ID
            )

            # Verify issuer
            if idinfo['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
                raise serializers.ValidationError('Wrong issuer.')

            return idinfo
        except ValueError:
            raise serializers.ValidationError('Invalid token')

class AppleAuthSerializer(serializers.Serializer):
    code = serializers.CharField(required=False)
    id_token = serializers.CharField(required=False)
    state = serializers.CharField(required=False)
    user = serializers.JSONField(required=False)

    def validate(self, data):
        if not data.get('code') and not data.get('id_token'):
            raise serializers.ValidationError(
                "Either 'code' or 'id_token' must be provided"
            )
        return data

    def verify_apple_token(self, id_token):
        try:
            # Get Apple's public key
            headers = jwt.get_unverified_header(id_token)
            key_id = headers.get('kid')
            
            # Fetch Apple's public keys
            response = requests.get('https://appleid.apple.com/auth/keys')
            if response.status_code != 200:
                raise serializers.ValidationError("Failed to fetch Apple public keys")
            
            keys = response.json()['keys']
            public_key = None
            
            # Find the matching key
            for key in keys:
                if key['kid'] == key_id:
                    public_key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(key))
                    break
            
            if not public_key:
                raise serializers.ValidationError("Invalid token: No matching key found")
            
            # Verify the token
            try:
                decoded = jwt.decode(
                    id_token,
                    public_key,
                    algorithms=['RS256'],
                    audience=settings.APPLE_AUTH_SETTINGS['BUNDLE_ID'],
                    issuer='https://appleid.apple.com'
                )
                return decoded
            except jwt.InvalidTokenError as e:
                raise serializers.ValidationError(f"Invalid token: {str(e)}")
            
        except Exception as e:
            raise serializers.ValidationError(f"Invalid Apple token: {str(e)}")

class PhoneAuthSerializer(serializers.Serializer):
    phone_number = PhoneNumberField()
    
    def validate_phone_number(self, phone_number):
        if User.objects.filter(phone_number=phone_number).exists():
            raise serializers.ValidationError("Phone number already registered")
        return phone_number

class VerifyPhoneSerializer(serializers.Serializer):
    phone_number = PhoneNumberField()
    verification_code = serializers.CharField(min_length=6, max_length=6)

    def validate(self, data):
        try:
            user = User.objects.get(
                phone_number=data['phone_number'],
                phone_verification_code=data['verification_code']
            )
            if not user.is_phone_verified:
                return data
            raise serializers.ValidationError("Phone already verified")
        except User.DoesNotExist:
            raise serializers.ValidationError("Invalid verification code")
