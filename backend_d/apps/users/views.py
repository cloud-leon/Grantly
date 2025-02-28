from django.shortcuts import render

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
    """New view using nested serializers"""
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        user = self.get_object()
        # Handle both multipart form data and JSON data
        if request.content_type and 'multipart/form-data' in request.content_type:
            data = {'profile': request.data}
        else:
            data = {'profile': request.data} if 'profile' not in request.data else request.data
            
        serializer = self.get_serializer(user, data=data, partial=True)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)

    def partial_update(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

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
