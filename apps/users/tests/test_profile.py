import pytest
from django.urls import reverse
from rest_framework import status
from datetime import date
import tempfile
from PIL import Image
import json
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model

pytestmark = pytest.mark.django_db

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def temp_image():
    """Create a temporary test image"""
    image = Image.new('RGB', (100, 100), color='red')
    tmp_file = tempfile.NamedTemporaryFile(suffix='.jpg')
    image.save(tmp_file)
    tmp_file.seek(0)
    return tmp_file

@pytest.fixture
def valid_profile_data():
    """Valid profile update data"""
    return {
        'first_name': 'Updated',
        'last_name': 'User',
        'bio': 'New bio',
        'interests': ['coding', 'reading', 'AI'],
        'education': {
            'school': 'Test University',
            'degree': 'BS',
            'field_of_study': 'Computer Science',
            'graduation_year': 2024
        },
        'skills': ['Python', 'Django', 'React'],
        'location': 'New York',
        'phone_number': '+12125552368'  # Valid US phone number format
    }

User = get_user_model()

class TestUserProfile:
    @pytest.fixture(autouse=True)
    def setup(self, api_client, test_user):
        self.client = api_client
        self.user = test_user
        self.client.force_authenticate(user=self.user)
        self.profile_url = reverse('users:profile')

    def test_get_profile(self):
        """Test retrieving user profile"""
        response = self.client.get(self.profile_url)
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['username'] == self.user.username
        assert 'email' in response.data
        assert 'interests' in response.data
        assert 'education' in response.data
        assert 'skills' in response.data

    def test_update_profile_full(self):
        update_data = {
            'first_name': 'John',
            'last_name': 'Doe',
            'date_of_birth': '1990-01-01',
            'bio': 'Test bio',
            'interests': ['coding', 'reading'],
            'education': {
                'school': 'Test University',
                'degree': 'Bachelor',
                'field_of_study': 'Computer Science',
                'graduation_year': 2020
            },
            'skills': ['Python', 'Django'],
            'phone_number': '+12125552368',  # Valid US phone number format
            'location': 'New York'
        }
        
        response = self.client.put(self.profile_url, update_data, format='json')
        assert response.status_code == status.HTTP_200_OK
        
        # Verify the updates
        user = User.objects.get(id=self.user.id)
        assert user.first_name == update_data['first_name']
        assert user.last_name == update_data['last_name']
        assert str(user.date_of_birth) == update_data['date_of_birth']
        assert user.bio == update_data['bio']
        assert user.interests == update_data['interests']
        assert user.education == update_data['education']
        assert user.skills == update_data['skills']
        assert str(user.phone_number) == update_data['phone_number']
        assert user.location == update_data['location']

    def test_partial_update_profile(self):
        """Test partial profile update"""
        update_data = {
            'bio': 'Updated bio',
            'interests': ['new interest']
        }
        
        response = self.client.patch(self.profile_url, update_data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['bio'] == update_data['bio']
        assert response.data['interests'] == update_data['interests']
        # Other fields should remain unchanged
        assert response.data['username'] == self.user.username

    def test_update_profile_with_image(self, temp_image):
        """Test profile update with image upload"""
        data = {
            'profile_picture': temp_image,
            'first_name': 'Image',
            'last_name': 'Test'
        }
        
        response = self.client.patch(
            self.profile_url,
            data,
            format='multipart'
        )
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['profile_picture'] is not None
        assert response.data['first_name'] == 'Image'

    def test_invalid_education_format(self):
        """Test updating with invalid education format"""
        invalid_data = {
            'education': {
                'school': 'Test University',
                # Missing required fields
            }
        }
        
        response = self.client.patch(self.profile_url, invalid_data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'education' in response.data

    def test_invalid_interests_format(self):
        """Test updating with invalid interests format"""
        invalid_data = {
            'interests': 'not a list'  # Should be a list
        }
        
        response = self.client.patch(self.profile_url, invalid_data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'interests' in response.data

    def test_invalid_skills_format(self):
        """Test updating with invalid skills format"""
        invalid_data = {
            'skills': {'key': 'value'}  # Should be a list
        }
        
        response = self.client.patch(self.profile_url, invalid_data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'skills' in response.data

    def test_update_profile_unauthenticated(self, valid_profile_data):
        """Test updating profile without authentication"""
        # Create a fresh client without authentication
        unauthenticated_client = APIClient()
        response = unauthenticated_client.put(self.profile_url, valid_profile_data, format='json')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_read_only_fields(self):
        """Test that read-only fields cannot be updated"""
        original_username = self.user.username
        original_email = self.user.email
        
        update_data = {
            'username': 'new_username',
            'email': 'newemail@example.com',
            'bio': 'This should update'
        }
        
        response = self.client.patch(self.profile_url, update_data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['username'] == original_username
        assert response.data['email'] == original_email
        assert response.data['bio'] == 'This should update' 