import os
import sys
import pytest
from pathlib import Path
from django.conf import settings

# Add the project root to Python path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# Set Django settings module
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
os.environ['PYTEST_RUNNING'] = 'True'

@pytest.fixture(autouse=True)
def enable_db_access_for_all_tests(db):
    pass

@pytest.fixture(autouse=True)
def disable_throttling(settings):
    """Disable throttling globally for all tests"""
    settings.REST_FRAMEWORK = {
        'DEFAULT_THROTTLE_CLASSES': [],
        'DEFAULT_THROTTLE_RATES': {},
        'DEFAULT_PERMISSION_CLASSES': [],
        'DEFAULT_AUTHENTICATION_CLASSES': [
            'rest_framework_simplejwt.authentication.JWTAuthentication',
        ],
        'TEST_REQUEST_DEFAULT_FORMAT': 'json'
    }
    # Remove throttling middleware
    settings.MIDDLEWARE = [
        m for m in settings.MIDDLEWARE
        if not m.endswith('.throttling.RequestRateThrottleMiddleware')
    ]

# Import your models here
from apps.users.models import User, UserProfile
from apps.scholarships.models import Scholarship, ScholarshipTag

# Your test fixtures below...
@pytest.fixture
def test_user(db):
    """Create test user with all required fields"""
    user = User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123',
        firebase_uid='test123'
    )
    # Create profile
    UserProfile.objects.create(
        user=user,
        phone_number='+1234567890'
    )
    return user

@pytest.fixture
def user():
    return User.objects.create_user(
        email='test@example.com',
        password='testpass123'
    )

@pytest.fixture
def scholarship_tag():
    return ScholarshipTag.objects.create(
        name='Test Tag'
    )

@pytest.fixture
def scholarship():
    return Scholarship.objects.create(
        title='Test Scholarship',
        description='Test Description',
        amount=1000.00,
        deadline='2024-12-31'
    ) 