"""
WSGI config for backend project.
"""

import os
import sys
from pathlib import Path

from django.core.wsgi import get_wsgi_application

# Add the project root directory to the Python path
current_path = Path(__file__).resolve().parent.parent
sys.path.append(str(current_path))

# Add the apps directory to the Python path
apps_path = current_path / "apps"
sys.path.append(str(apps_path))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')

application = get_wsgi_application() 