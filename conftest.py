import os
import sys
import django
from django.conf import settings

# Set testing environment variables
os.environ['PYTEST_RUNNING'] = 'True'
os.environ['DJANGO_SETTINGS_MODULE'] = 'backend.settings'

# Add both the project root and the apps directory to the Python path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__)))
sys.path.insert(0, project_root)
sys.path.insert(0, os.path.join(project_root, 'apps'))

# Configure Django
django.setup()

# Add your fixtures here
import pytest
from rest_framework.test import APIClient

@pytest.fixture
def client():
    return APIClient()

@pytest.fixture
def django_db_setup(django_db_setup, django_db_blocker):
    with django_db_blocker.unblock():
        yield 