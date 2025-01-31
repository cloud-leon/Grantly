import pytest
from django.utils import timezone
from datetime import timedelta
from apps.scholarships.serializers import (
    ScholarshipTagSerializer,
    ScholarshipListSerializer,
    ScholarshipDetailSerializer,
    ScholarshipCreateSerializer
)

pytestmark = pytest.mark.django_db

class TestScholarshipTagSerializer:
    def test_serializer_with_valid_data(self):
        data = {
            'name': 'Engineering',
            'description': 'Engineering scholarships'
        }
        serializer = ScholarshipTagSerializer(data=data)
        assert serializer.is_valid()
        tag = serializer.save()
        assert tag.slug == 'engineering'

class TestScholarshipSerializers:
    def test_list_serializer(self, active_scholarship):
        serializer = ScholarshipListSerializer(active_scholarship)
        data = serializer.data
        assert data['title'] == active_scholarship.title
        assert 'description' not in data

    def test_detail_serializer(self, active_scholarship):
        serializer = ScholarshipDetailSerializer(active_scholarship)
        data = serializer.data
        assert data['title'] == active_scholarship.title
        assert data['description'] == active_scholarship.description
        assert len(data['tags']) == 1

    def test_create_serializer_with_past_deadline(self):
        data = {
            'title': 'Test',
            'description': 'Test',
            'amount': '1000.00',
            'deadline': (timezone.now().date() - timedelta(days=1)).isoformat(),
            'eligibility_criteria': 'Test'
        }
        serializer = ScholarshipCreateSerializer(data=data)
        assert not serializer.is_valid()
        assert 'deadline' in serializer.errors

    def test_create_serializer_with_invalid_amount(self):
        data = {
            'title': 'Test',
            'description': 'Test',
            'amount': '-1000.00',
            'deadline': (timezone.now().date() + timedelta(days=30)).isoformat(),
            'eligibility_criteria': 'Test'
        }
        serializer = ScholarshipCreateSerializer(data=data)
        assert not serializer.is_valid()
        assert 'amount' in serializer.errors 