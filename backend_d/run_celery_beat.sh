#!/bin/bash
source ../venv/bin/activate
celery -A config beat -l INFO 