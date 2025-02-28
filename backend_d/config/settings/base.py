from .database import get_database_config

# ... other settings ...

DATABASES = get_database_config()

AUTH_USER_MODEL = 'users.User'

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.postgres',
    
    # Third party apps
    'rest_framework',
    'corsheaders',
    
    # Local apps
    'apps.users.apps.UsersConfig',
    'apps.applications.apps.ApplicationsConfig',
    'apps.scholarships.apps.ScholarshipsConfig',
] 