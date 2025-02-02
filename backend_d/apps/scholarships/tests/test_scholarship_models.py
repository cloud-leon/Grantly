import pytest
from django.utils import timezone
from datetime import timedelta
from apps.scholarships.models import Scholarship, ScholarshipTag

pytestmark = pytest.mark.django_db

class TestScholarshipTag:
    def test_tag_creation(self):
        tag = ScholarshipTag.objects.create(
            name='Engineering',
            description='Engineering scholarships'
        )
        assert tag.slug == 'engineering'
        assert str(tag) == 'Engineering'

    def test_unique_name(self):
        ScholarshipTag.objects.create(name='Engineering')
        with pytest.raises(Exception):
            ScholarshipTag.objects.create(name='Engineering')

    def test_scholarship_count(self, scholarship_tag, active_scholarship):
        assert scholarship_tag.get_scholarships_count() == 1

class TestScholarship:
    def test_scholarship_creation(self, active_scholarship):
        assert str(active_scholarship) == 'Test Scholarship'
        assert active_scholarship.is_active == True

    def test_expired_status(self, expired_scholarship):
        assert expired_scholarship.is_expired == True

    def test_active_status(self, active_scholarship):
        assert active_scholarship.is_expired == False

    def test_get_by_tag(self, scholarship_tag, active_scholarship):
        scholarships = Scholarship.get_by_tag(scholarship_tag.slug)
        assert scholarships.count() == 1
        assert scholarships.first() == active_scholarship

    def test_get_active_tags(self, scholarship_tag, active_scholarship):
        tags = Scholarship.get_active_tags()
        assert tags.count() == 1
        assert tags.first() == scholarship_tag 