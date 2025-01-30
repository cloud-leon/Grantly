import os
import sys
import django
from django.conf import settings
import pytest
from rest_framework.test import APIClient
import tempfile
from django.core.management import call_command

# Set testing environment variables
os.environ['PYTEST_RUNNING'] = 'True'
os.environ['DJANGO_SETTINGS_MODULE'] = 'backend.settings'

# Add project root and apps directory to Python path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__)))
sys.path.insert(0, project_root)
sys.path.insert(0, os.path.join(project_root, 'apps'))

# Configure Django
django.setup()

@pytest.fixture(scope='session')
def django_db_setup(django_db_setup, django_db_blocker):
    """Ensure test database is created and migrated before tests"""
    with django_db_blocker.unblock():
        try:
            # Run migrations
            call_command('migrate', '--noinput', verbosity=0)
        except Exception as e:
            print(f"Migration failed: {e}")
            raise

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def test_user(django_user_model):
    """Create a test user"""
    return django_user_model.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123'
    )

@pytest.fixture(autouse=True)
def media_storage(settings, tmpdir):
    """Configure media storage for tests"""
    settings.MEDIA_ROOT = tmpdir.strpath 