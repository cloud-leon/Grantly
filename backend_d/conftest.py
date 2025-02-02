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

# Import your models here
from apps.users.models import User
from apps.scholarships.models import Scholarship, ScholarshipTag

# Your test fixtures below...
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