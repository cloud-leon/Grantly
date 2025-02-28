import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent

def get_database_config():
    """
    Get database configuration based on environment settings
    """
    if os.environ.get('USE_SQLITE', 'False').lower() == 'true':
        # SQLite configuration
        return {
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': BASE_DIR / 'db.sqlite3',
            }
        }
    else:
        # PostgreSQL configuration
        return {
            'default': {
                'ENGINE': 'django.db.backends.postgresql',
                'NAME': os.environ.get('DB_NAME', 'scholarship_db'),
                'USER': os.environ.get('DB_USER', 'scholarship_user'),
                'PASSWORD': os.environ.get('DB_PASSWORD', 'scholarship_password'),
                'HOST': os.environ.get('DB_HOST', 'localhost'),
                'PORT': os.environ.get('DB_PORT', '5432'),
            }
        } 