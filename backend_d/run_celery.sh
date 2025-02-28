#!/bin/bash
source ../venv/bin/activate
celery -A config worker -l INFO
python manage.py migrate django_celery_beat 