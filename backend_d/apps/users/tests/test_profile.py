import pytest
from django.urls import reverse
from rest_framework import status
from datetime import date
import tempfile
from PIL import Image
import json
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model
from apps.users.models.profile import UserProfile
from django.test import TestCase
from freezegun import freeze_time
from django.utils import timezone

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

class ProfileTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass123'
        )
        self.client.force_authenticate(user=self.user)
        
        self.profile_data = {
            'firebase_uid': 'test123',
            'first_name': 'Test',
            'last_name': 'User',
            'date_of_birth': '2000-01-01',
            'email': 'test@example.com',
            'phone_number': '+1234567890',
            'gender': 'Male',
            'race': 'White/Caucasian',
            'disabilities': 'No',
            'military': 'No',
            'grade_level': 'College Freshman',
            'financial_aid': 'Yes',
            'first_gen': 'Yes',
            'citizenship': 'US Citizen',
            'field_of_study': 'Computer Science',
            'career_goals': 'Software Engineer',
            'education_level': 'undergraduate',
            'interests': ['Programming', 'AI'],
            'education': {'level': 'undergraduate', 'field': 'Computer Science'},
            'skills': ['Python', 'Django']
        }

    def test_create_profile(self):
        """Test creating a new profile"""
        url = reverse('users:profile-create')
        
        # Delete existing profile if it exists
        UserProfile.objects.filter(user=self.user).delete()
        
        # Print request data for debugging
        print("Request data:", self.profile_data)
        
        response = self.client.post(url, self.profile_data, format='json')
        
        # Print response data for debugging
        print("Response status:", response.status_code)
        print("Response data:", response.data)
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        profile = UserProfile.objects.get(user=self.user)
        self.assertEqual(profile.first_name, self.profile_data['first_name'])
        self.assertEqual(profile.last_name, self.profile_data['last_name'])
        self.assertEqual(profile.education_level, self.profile_data['education_level'])
        self.assertEqual(profile.interests, self.profile_data['interests'])
        self.assertEqual(profile.education, self.profile_data['education'])
        self.assertEqual(profile.skills, self.profile_data['skills'])

    def test_update_profile(self):
        """Test updating an existing profile"""
        profile = self.user.profile
        for key, value in self.profile_data.items():
            setattr(profile, key, value)
        profile.save()
        
        update_data = {
            'first_name': 'Updated',
            'last_name': 'Name',
            'field_of_study': 'Data Science'
        }
        
        url = reverse('users:profile-update', kwargs={'pk': profile.pk})
        response = self.client.patch(url, update_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        profile.refresh_from_db()
        self.assertEqual(profile.first_name, update_data['first_name'])
        self.assertEqual(profile.field_of_study, update_data['field_of_study'])

    def test_grade_level_formatting(self):
        """Test the grade level formatting method"""
        profile = self.user.profile
        profile.grade_level = 'College Freshman'
        profile.save()
        
        with freeze_time('2024-03-01'):
            formatted = profile.get_formatted_grade_level()
            self.assertEqual(formatted, 'College Freshman (Class of 2028)')

    # Add more tests as needed...

@pytest.mark.django_db
class TestUserProfile:
    @pytest.fixture(autouse=True)
    def setup(self, api_client, test_user):
        self.client = api_client
        self.user = test_user
        self.profile = UserProfile.objects.get(user=self.user)
        self.client.force_authenticate(user=self.user)
        self.profile_url = '/api/users/profile/v2/'

    def test_get_profile(self):
        response = self.client.get(self.profile_url)
        assert response.status_code == 200
        # Check for nested profile data
        assert response.data['id'] == self.user.id
        assert 'profile' in response.data

    def test_update_profile_full(self):
        data = {
            'profile': {
                'date_of_birth': '1990-01-01',
                'bio': 'Updated bio',
                'user_type': 'student',
                'interests': ['Programming', 'AI'],
                'education': {'degree': 'BS', 'field': 'CS'},
                'skills': ['Python', 'Django']
            }
        }
        response = self.client.patch(self.profile_url, data, format='json')
        assert response.status_code == 200
        self.profile.refresh_from_db()
        assert str(self.profile.date_of_birth) == data['profile']['date_of_birth']

    def test_update_profile_with_image(self, temp_image):
        # For multipart form data, we can't use nested data
        data = {
            'profile_picture': temp_image,
            'bio': 'Image Test'
        }
        response = self.client.patch(
            self.profile_url,
            data,
            format='multipart'
        )
        assert response.status_code == 200
        self.profile.refresh_from_db()
        assert 'profile_picture' in response.data['profile']
        assert response.data['profile']['bio'] == 'Image Test'

    def test_invalid_education_format(self):
        data = {
            'profile': {
                'education': 'not a dict'  # Invalid format
            }
        }
        response = self.client.patch(self.profile_url, data, format='json')
        assert response.status_code == 400
        assert 'profile' in response.data
        assert 'education' in response.data['profile']

    def test_invalid_interests_format(self):
        """Test updating with invalid interests format"""
        data = {
            'profile': {
                'interests': 'not a list'  # Should be a list
            }
        }
        response = self.client.patch(self.profile_url, data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'profile' in response.data
        assert 'interests' in response.data['profile']

    def test_invalid_skills_format(self):
        """Test updating with invalid skills format"""
        data = {
            'profile': {
                'skills': {'key': 'value'}  # Should be a list
            }
        }
        response = self.client.patch(self.profile_url, data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'profile' in response.data
        assert 'skills' in response.data['profile']

    def test_update_profile_unauthenticated(self, valid_profile_data):
        """Test updating profile without authentication"""
        unauthenticated_client = APIClient()
        response = unauthenticated_client.put(self.profile_url, valid_profile_data, format='json')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_read_only_fields(self):
        """Test that read-only fields cannot be updated"""
        original_username = self.user.username
        original_email = self.user.email
        
        update_data = {
            'profile': {
                'bio': 'This should update'
            },
            'username': 'new_username',
            'email': 'newemail@example.com'
        }
        
        response = self.client.patch(self.profile_url, update_data, format='json')
        
        assert response.status_code == status.HTTP_200_OK
        self.profile.refresh_from_db()
        assert response.data['username'] == original_username
        assert response.data['email'] == original_email
        assert self.profile.bio == 'This should update'

    # Update other tests similarly... 