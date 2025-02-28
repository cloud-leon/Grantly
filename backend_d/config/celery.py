import os
from celery import Celery
from celery.schedules import crontab
from django.conf import settings

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

app = Celery('scholarship_app')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

app.conf.beat_schedule = {
    'update-grade-levels-daily': {
        'task': 'apps.users.tasks.update_grade_levels',
        'schedule': crontab(hour=0, minute=0),
        'options': {
            'queue': 'scheduled',
            'retry': True,
            'retry_policy': {
                'max_retries': 3,
                'interval_start': 0,
                'interval_step': 0.2,
                'interval_max': 0.6,
            }
        }
    }
} 