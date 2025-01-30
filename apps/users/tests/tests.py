from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from datetime import date
from django.forms import ModelForm

User = get_user_model()

class AuthenticationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.register_url = reverse('users:register')
        self.login_url = reverse('users:login')
        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password2': 'testpass123'  # If your registration requires password confirmation
        }
        self.login_data = {
            'username': 'testuser',
            'password': 'testpass123'
        }

    def test_user_registration(self):
        """Test user registration"""
        response = self.client.post(self.register_url, self.user_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(username='testuser').exists())

    def test_user_login(self):
        """Test user login and JWT token generation"""
        # First create a user
        User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

        # Try to login
        response = self.client.post(self.login_url, self.login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)

    def test_invalid_login(self):
        """Test login with invalid credentials"""
        invalid_data = {
            'username': 'testuser',
            'password': 'wrongpass'
        }
        response = self.client.post(self.login_url, invalid_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_protected_endpoint_with_token(self):
        """Test accessing a protected endpoint with JWT token"""
        # Create a user and get their token
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        login_response = self.client.post(self.login_url, self.login_data, format='json')
        token = login_response.data['access']

        # Try to access a protected endpoint
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        response = self.client.get(reverse('users:protected-endpoint'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_protected_endpoint_without_token(self):
        """Test accessing a protected endpoint without JWT token"""
        response = self.client.get(reverse('users:protected-endpoint'))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

class UserModelTest(TestCase):
    def setUp(self):
        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'user_type': 'student',
            'date_of_birth': date(2000, 1, 1),
            'bio': 'Test bio'
        }
        self.user = User.objects.create_user(**self.user_data)

    def test_user_creation(self):
        """Test that a user can be created with all fields"""
        self.assertEqual(self.user.username, 'testuser')
        self.assertEqual(self.user.email, 'test@example.com')
        self.assertEqual(self.user.user_type, 'student')
        self.assertEqual(self.user.date_of_birth, date(2000, 1, 1))
        self.assertEqual(self.user.bio, 'Test bio')

    def test_user_type_choices(self):
        """Test that user_type only accepts valid choices"""
        # Test valid choices
        self.user.user_type = 'student'
        self.user.full_clean()  # Should not raise
        
        self.user.user_type = 'admin'
        self.user.full_clean()  # Should not raise

        # Test invalid choice
        self.user.user_type = 'invalid_type'
        with self.assertRaises(ValidationError):
            self.user.full_clean()

    def test_default_user_type(self):
        """Test that default user_type is 'student'"""
        new_user = User.objects.create_user(
            username='defaultuser',
            email='default@example.com',
            password='testpass123'
        )
        self.assertEqual(new_user.user_type, 'student')

    def test_optional_fields(self):
        """Test that date_of_birth and bio are optional"""
        optional_user = User.objects.create_user(
            username='optionaluser',
            email='optional@example.com',
            password='testpass123'
        )
        self.assertIsNone(optional_user.date_of_birth)
        self.assertEqual(optional_user.bio, '')

    def test_bio_max_length(self):
        """Test that bio respects max_length"""
        class UserForm(ModelForm):
            class Meta:
                model = User
                fields = ['bio']
        
        # Test exceeding max_length
        form = UserForm(data={'bio': 'a' * 501})
        self.assertFalse(form.is_valid())
        
        # Test exactly max_length
        form = UserForm(data={'bio': 'a' * 500})
        self.assertTrue(form.is_valid())

class UserEndpointsTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.register_url = reverse('users:register')
        self.login_url = reverse('users:login')
        self.protected_url = reverse('users:protected-endpoint')
        
        # Test user data
        self.user_data = {
            'username': 'testuser',
            'password': 'testpass123',
            'email': 'test@example.com',
            'password2': 'testpass123'
        }
        
        # Create a test user for login tests
        self.test_user = User.objects.create_user(
            username='existinguser',
            password='existing123',
            email='existing@example.com'
        )

    def test_register_success(self):
        """Test successful user registration"""
        response = self.client.post(self.register_url, self.user_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(username='testuser').exists())

    def test_register_invalid_data(self):
        """Test registration with invalid data"""
        invalid_data = {
            'username': '',  # Empty username
            'password': 'test123'
        }
        response = self.client.post(self.register_url, invalid_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_success(self):
        """Test successful login"""
        login_data = {
            'username': 'existinguser',
            'password': 'existing123'
        }
        response = self.client.post(self.login_url, login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)

    def test_login_invalid_credentials(self):
        """Test login with invalid credentials"""
        invalid_login = {
            'username': 'existinguser',
            'password': 'wrongpassword'
        }
        response = self.client.post(self.login_url, invalid_login, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_protected_endpoint_with_auth(self):
        """Test accessing protected endpoint with authentication"""
        # First login to get the token
        login_data = {
            'username': 'existinguser',
            'password': 'existing123'
        }
        login_response = self.client.post(self.login_url, login_data, format='json')
        token = login_response.data['access']

        # Access protected endpoint with token
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        response = self.client.get(self.protected_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_protected_endpoint_without_auth(self):
        """Test accessing protected endpoint without authentication"""
        response = self.client.get(self.protected_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)