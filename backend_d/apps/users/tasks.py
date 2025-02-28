from celery import shared_task
from django.db import connection
from celery.utils.log import get_task_logger

logger = get_task_logger(__name__)

@shared_task(
    bind=True,
    retry_backoff=True,
    max_retries=3,
    name='users.update_grade_levels'
)
def update_grade_levels(self):
    """Update student grade levels based on current date"""
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT update_class_years();")
            logger.info("Successfully updated grade levels")
    except Exception as exc:
        logger.error(f"Failed to update grade levels: {exc}")
        self.retry(exc=exc) 