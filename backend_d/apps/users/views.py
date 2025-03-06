from django.shortcuts import render
from django.db import transaction
from django.core.cache import cache

# Create your views here.
from rest_framework import status, permissions, generics, views, serializers, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate, get_user_model
from django.utils.http import urlsafe_base64_decode
from django.conf import settings
from twilio.rest import Client
import random
from rest_framework.exceptions import ValidationError
from firebase_admin import auth
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.core.exceptions import ObjectDoesNotExist
from django.urls import path

from .serializers import UserRegistrationSerializer, UserLoginSerializer, PasswordResetSerializer, PasswordResetConfirmSerializer, UserProfileSerializer, GoogleAuthSerializer, AppleAuthSerializer, PhoneAuthSerializer, VerifyPhoneSerializer, UserSerializer, ProfileSerializer
from .models import User, UserProfile

User = get_user_model()

class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                {"message": "User created successfully"},
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        serializer = UserLoginSerializer(data=request.data)
        if serializer.is_valid():
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_401_UNAUTHORIZED)

class ProtectedView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        return Response({"message": "You have access to this endpoint"})

class PasswordResetView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        serializer = PasswordResetSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {"message": "Password reset email has been sent."},
                status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PasswordResetConfirmView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request, uidb64, token):
        serializer = PasswordResetConfirmSerializer(
            data={
                'password': request.data.get('password'),
                'password2': request.data.get('password2'),
                'token': token,
                'uidb64': uidb64,
            }
        )
        if serializer.is_valid():
            serializer.save()
            return Response(
                {"message": "Password has been reset successfully."},
                status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserProfileView(generics.RetrieveUpdateAPIView):
    """Legacy view - kept for backward compatibility"""
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

class ProfileViewSet(viewsets.ModelViewSet):
    """ViewSet for managing user profiles"""
    serializer_class = UserProfileSerializer
    queryset = UserProfile.objects.all()

    def get_queryset(self):
        """Filter queryset to only return the authenticated user's profile"""
        if self.action == 'list':
            return UserProfile.objects.none()  # Don't allow listing all profiles
        return UserProfile.objects.all()

    def perform_create(self, serializer):
        """Create a new profile"""
        try:
            # Get Firebase UID from token
            auth_header = self.request.headers.get('Authorization')
            decoded_token = auth.verify_id_token(auth_header)
            firebase_uid = decoded_token['uid']
            
            # Create profile with Firebase UID
            serializer.save(firebase_uid=firebase_uid)
        except Exception as e:
            print(f"Error creating profile: {e}")
            raise ValidationError("Invalid authentication token")

    def perform_update(self, serializer):
        """Update existing profile"""
        try:
            # Verify Firebase token matches profile
            auth_header = self.request.headers.get('Authorization')
            decoded_token = auth.verify_id_token(auth_header)
            firebase_uid = decoded_token['uid']
            
            # Only allow updating if Firebase UID matches
            if serializer.instance.firebase_uid != firebase_uid:
                raise ValidationError("Not authorized to update this profile")
            
            serializer.save()
        except Exception as e:
            print(f"Error updating profile: {e}")
            raise ValidationError("Invalid authentication token")

class GoogleAuthView(APIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = GoogleAuthSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Get validated Google user data
        google_data = serializer.validated_data['token']
        
        google_id = google_data.get('sub')
        email = google_data.get('email')
        first_name = google_data.get('given_name', '')
        last_name = google_data.get('family_name', '')
        
        # Get or create user
        user, created = User.objects.get_or_create(
            google_id=google_id,
            defaults={
                'email': email,
                'username': email or f'google_user_{google_id}',
                'first_name': first_name,
                'last_name': last_name,
            }
        )
        
        # Generate tokens
        refresh = RefreshToken.for_user(user)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        })

class AppleAuthView(views.APIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = AppleAuthSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Verify the Apple ID token
        id_token = serializer.validated_data.get('id_token')
        if id_token:
            try:
                apple_data = serializer.verify_apple_token(id_token)
            except serializers.ValidationError as e:
                return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
            
            apple_id = apple_data.get('sub')
            email = apple_data.get('email')
            
            # Get user data if provided
            user_data = serializer.validated_data.get('user', {})
            name = user_data.get('name', {})
            first_name = name.get('firstName', '')
            last_name = name.get('lastName', '')
            
            user, created = User.objects.get_or_create(
                apple_id=apple_id,
                defaults={
                    'email': email,
                    'username': email or f'apple_user_{apple_id}',
                    'first_name': first_name,
                    'last_name': last_name,
                }
            )
            
            refresh = RefreshToken.for_user(user)
            return Response({
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            })
        
        return Response(
            {'error': 'No valid authentication data provided'},
            status=status.HTTP_400_BAD_REQUEST
        )

class PhoneAuthView(views.APIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = PhoneAuthSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        phone_number = serializer.validated_data['phone_number']
        verification_code = str(random.randint(100000, 999999))
        
        # Send SMS using Twilio
        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        message = client.messages.create(
            body=f'Your verification code is: {verification_code}',
            from_=settings.TWILIO_PHONE_NUMBER,
            to=str(phone_number)
        )
        
        user, created = User.objects.get_or_create(
            phone_number=phone_number,
            defaults={
                'username': f'user_{phone_number}',
                'phone_verification_code': verification_code
            }
        )
        
        if not created:
            user.phone_verification_code = verification_code
            user.save()
        
        return Response({'message': 'Verification code sent'})

class VerifyPhoneView(views.APIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = VerifyPhoneSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        phone_number = serializer.validated_data['phone_number']
        user = User.objects.get(phone_number=phone_number)
        user.is_phone_verified = True
        user.phone_verification_code = None
        user.save()
        
        refresh = RefreshToken.for_user(user)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        })

class ProfileUpdateView(generics.UpdateAPIView):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_update(self, serializer):
        if 'interests' in self.request.data and not isinstance(self.request.data['interests'], list):
            raise ValidationError({'interests': 'Must be a list'})
        if 'skills' in self.request.data and not isinstance(self.request.data['skills'], list):
            raise ValidationError({'skills': 'Must be a list'})
        if 'education' in self.request.data and not isinstance(self.request.data['education'], dict):
            raise ValidationError({'education': 'Must be a dictionary'})
        serializer.save()

class ProfileCreateView(generics.CreateAPIView):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request, *args, **kwargs):
        try:
            profile = request.user.profile
            # Update existing profile
            serializer = self.get_serializer(profile, data=request.data)
        except UserProfile.DoesNotExist:
            # Create new profile
            serializer = self.get_serializer(data=request.data)
        
        serializer.is_valid(raise_exception=True)
        
        # Save the profile
        if hasattr(request.user, 'profile'):
            self.perform_update(serializer)
        else:
            self.perform_create(serializer)
            
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def perform_update(self, serializer):
        serializer.save()

@api_view(['GET'])
@permission_classes([AllowAny])
def get_profile(request):
    try:
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return Response({'error': 'Invalid token format'}, status=status.HTTP_401_UNAUTHORIZED)
        
        token = auth_header.split(' ')[1]
        
        try:
            decoded_token = auth.verify_id_token(token)
            firebase_uid = decoded_token['uid']
            print(f"Getting profile for Firebase UID: {firebase_uid}")
            
            # First try to get profile by firebase_uid
            try:
                profile = UserProfile.objects.select_related('user').get(firebase_uid=firebase_uid)
                print(f"Found profile with ID: {profile.id}")
                serializer = UserProfileSerializer(profile)
                return Response(serializer.data, status=status.HTTP_200_OK)
            except UserProfile.DoesNotExist:
                print(f"No profile found for Firebase UID: {firebase_uid}")
                return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)
            
        except Exception as e:
            print(f"Token verification failed: {e}")
            return Response({'error': f'Token verification failed: {str(e)}'}, 
                          status=status.HTTP_401_UNAUTHORIZED)
            
    except Exception as e:
        print(f"Error in get_profile: {str(e)}")
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class ProfileView(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = ProfileSerializer

    def get_object(self):
        return UserProfile.objects.get(user=self.request.user)

@api_view(['POST'])
@permission_classes([AllowAny])
@transaction.atomic
def create_profile(request):
    print("\n=== Profile Creation Request ===")
    print(f"Request Data: {request.data}")
    
    try:
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return Response({'error': 'Invalid token format'}, status=status.HTTP_401_UNAUTHORIZED)
        
        token = auth_header.split(' ')[1]
        
        try:
            decoded_token = auth.verify_id_token(token)
            firebase_uid = decoded_token['uid']
            phone_number = decoded_token.get('phone_number', '')
            
            print(f"Firebase UID from token: {firebase_uid}")
            
            with transaction.atomic():
                # Delete existing profiles
                UserProfile.objects.filter(firebase_uid=firebase_uid).delete()
                
                # Get or create user with unique username
                try:
                    user = User.objects.get(firebase_uid=firebase_uid)
                except User.DoesNotExist:
                    # Generate unique username
                    base_username = phone_number or firebase_uid
                    username = base_username
                    counter = 1
                    while User.objects.filter(username=username).exists():
                        username = f"{base_username}_{counter}"
                        counter += 1
                    
                    user = User.objects.create(
                        username=username,
                        firebase_uid=firebase_uid,
                        phone_number=phone_number,
                        is_phone_verified=True
                    )
                
                # Create new profile
                profile_data = request.data.copy()
                profile_data['user'] = user.id
                profile_data['firebase_uid'] = firebase_uid
                
                # Convert boolean strings to proper format
                bool_fields = ['disabilities', 'military', 'financial_aid', 'first_gen']
                for field in bool_fields:
                    if field in profile_data:
                        value = profile_data[field]
                        if isinstance(value, str):
                            profile_data[field] = value
                        else:
                            profile_data[field] = 'Yes' if value else 'No'
                
                serializer = UserProfileSerializer(data=profile_data)
                if serializer.is_valid():
                    profile = serializer.save()
                    print(f"Profile created successfully with ID: {profile.id}")
                    return Response(serializer.data, status=status.HTTP_201_CREATED)
                
                print(f"Validation errors: {serializer.errors}")
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
        except Exception as e:
            print(f"Error during profile creation: {str(e)}")
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
    except Exception as e:
        print(f"Unexpected error in create_profile: {str(e)}")
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    return Response({"status": "healthy"}, status=status.HTTP_200_OK)
