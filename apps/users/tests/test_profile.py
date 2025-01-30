import pytest
from django.urls import reverse
from rest_framework import status
from datetime import date
import tempfile
from PIL import Image
import json

pytestmark = pytest.mark.django_db

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
        'phone_number': '+1234567890'
    }

class TestUserProfile:
    def test_get_profile(self, api_client, test_user):
        """Test retrieving user profile"""
        url = reverse('users:profile')
        api_client.force_authenticate(user=test_user)
        response = api_client.get(url)
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['username'] == test_user.username
        assert 'email' in response.data
        assert 'interests' in response.data
        assert 'education' in response.data
        assert 'skills' in response.data

    def test_update_profile_full(self, api_client, test_user, valid_profile_data):
        """Test full profile update"""
        url = reverse('users:profile')
        api_client.force_authenticate(user=test_user)
        
        response = api_client.put(url, valid_profile_data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['first_name'] == valid_profile_data['first_name']
        assert response.data['last_name'] == valid_profile_data['last_name']
        assert response.data['interests'] == valid_profile_data['interests']
        assert response.data['education'] == valid_profile_data['education']
        assert response.data['skills'] == valid_profile_data['skills']
        assert response.data['location'] == valid_profile_data['location']

    def test_partial_update_profile(self, api_client, test_user):
        """Test partial profile update"""
        url = reverse('users:profile')
        api_client.force_authenticate(user=test_user)
        
        update_data = {
            'bio': 'Updated bio',
            'interests': ['new interest']
        }
        
        response = api_client.patch(url, update_data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['bio'] == update_data['bio']
        assert response.data['interests'] == update_data['interests']
        # Other fields should remain unchanged
        assert response.data['username'] == test_user.username

    def test_update_profile_with_image(self, api_client, test_user, temp_image):
        """Test profile update with image upload"""
        url = reverse('users:profile')
        api_client.force_authenticate(user=test_user)
        
        data = {
            'profile_picture': temp_image,
            'first_name': 'Image',
            'last_name': 'Test'
        }
        
        response = api_client.patch(
            url,
            data,
            format='multipart'
        )
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['profile_picture'] is not None
        assert response.data['first_name'] == 'Image'

    def test_invalid_education_format(self, api_client, test_user):
        """Test updating with invalid education format"""
        url = reverse('users:profile')
        api_client.force_authenticate(user=test_user)
        
        invalid_data = {
            'education': {
                'school': 'Test University',
                # Missing required fields
            }
        }
        
        response = api_client.patch(url, invalid_data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'education' in response.data

    def test_invalid_interests_format(self, api_client, test_user):
        """Test updating with invalid interests format"""
        url = reverse('users:profile')
        api_client.force_authenticate(user=test_user)
        
        invalid_data = {
            'interests': 'not a list'  # Should be a list
        }
        
        response = api_client.patch(url, invalid_data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'interests' in response.data

    def test_invalid_skills_format(self, api_client, test_user):
        """Test updating with invalid skills format"""
        url = reverse('users:profile')
        api_client.force_authenticate(user=test_user)
        
        invalid_data = {
            'skills': {'key': 'value'}  # Should be a list
        }
        
        response = api_client.patch(url, invalid_data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'skills' in response.data

    def test_update_profile_unauthenticated(self, api_client, valid_profile_data):
        """Test updating profile without authentication"""
        url = reverse('users:profile')
        response = api_client.put(url, valid_profile_data, format='json')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_read_only_fields(self, api_client, test_user):
        """Test that read-only fields cannot be updated"""
        url = reverse('users:profile')
        api_client.force_authenticate(user=test_user)
        
        original_username = test_user.username
        original_email = test_user.email
        
        update_data = {
            'username': 'new_username',
            'email': 'newemail@example.com',
            'bio': 'This should update'
        }
        
        response = api_client.patch(url, update_data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['username'] == original_username
        assert response.data['email'] == original_email
        assert response.data['bio'] == 'This should update' 