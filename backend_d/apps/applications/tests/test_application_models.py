import pytest
from django.utils import timezone
from django.core.exceptions import ValidationError
from apps.applications.models import Application

pytestmark = pytest.mark.django_db

class TestApplication:
    def test_application_creation(self, application):
        assert str(application) == f"{application.user.username}'s application for {application.scholarship.title}"
        assert application.status == 'pending'
        assert application.swipe_status == 'right'

    def test_unique_constraint(self, test_user, active_scholarship):
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            status='pending'
        )
        with pytest.raises(Exception):
            Application.objects.create(
                user=test_user,
                scholarship=active_scholarship,
                status='pending'
            )

    def test_default_values(self, test_user, active_scholarship):
        application = Application.objects.create(
            user=test_user,
            scholarship=active_scholarship
        )
        assert application.status == 'pending'
        assert application.swipe_status == 'saved'
        assert application.answers == {}
        assert application.documents == []
        assert application.submitted_at is None

    def test_invalid_status(self, test_user, active_scholarship):
        with pytest.raises(ValidationError):
            application = Application.objects.create(
                user=test_user,
                scholarship=active_scholarship,
                status='invalid_status'
            )
            application.full_clean()

    def test_invalid_swipe_status(self, test_user, active_scholarship):
        with pytest.raises(ValidationError):
            application = Application.objects.create(
                user=test_user,
                scholarship=active_scholarship,
                swipe_status='invalid_swipe'
            )
            application.full_clean()

    def test_answers_json_validation(self, test_user, active_scholarship):
        # Test valid JSON
        application = Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            answers={'question1': 'answer1'}
        )
        assert application.answers == {'question1': 'answer1'}

        # Test invalid JSON (should still work as Django converts it)
        application.answers = 'invalid json'
        application.save()
        application.refresh_from_db()
        assert application.answers == 'invalid json' 