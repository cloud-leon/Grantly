import pytest
from django.utils import timezone
from datetime import timedelta
from apps.scholarships.serializers import (
    ScholarshipTagSerializer,
    ScholarshipListSerializer,
    ScholarshipDetailSerializer,
    ScholarshipCreateSerializer
)
from apps.scholarships.models import Scholarship

pytestmark = pytest.mark.django_db

@pytest.fixture
def scholarship_data():
    """Fixture for valid scholarship data"""
    return {
        'title': 'Test Scholarship',
        'description': 'Test Description',
        'amount': '1000.00',
        'deadline': (timezone.now().date() + timedelta(days=30)).isoformat(),
        'eligibility_criteria': 'Test Criteria'
    }

@pytest.fixture
def scholarship(scholarship_data):
    """Fixture for a scholarship instance"""
    return Scholarship.objects.create(**scholarship_data)

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

    def test_create_serializer_with_missing_required_fields(self):
        """Test serializer validation with missing required fields"""
        data = {}  # Empty data
        
        serializer = ScholarshipCreateSerializer(data=data)
        assert not serializer.is_valid()
        assert 'title' in serializer.errors
        assert 'description' in serializer.errors

    def test_create_serializer_with_invalid_url(self, scholarship_data):
        """Test serializer validation with invalid URL format"""
        scholarship_data['application_url'] = 'not-a-valid-url'
        
        serializer = ScholarshipCreateSerializer(data=scholarship_data)
        assert not serializer.is_valid()
        assert 'application_url' in serializer.errors

    def test_update_serializer(self, scholarship):
        """Test serializer update functionality"""
        update_data = {
            'title': 'Updated Scholarship Name',
            'amount': '2000.00'
        }
        
        serializer = ScholarshipCreateSerializer(
            instance=scholarship,
            data=update_data,
            partial=True
        )
        assert serializer.is_valid()
        updated_scholarship = serializer.save()
        
        assert updated_scholarship.title == 'Updated Scholarship Name'
        assert str(updated_scholarship.amount) == '2000.00'

    def test_serializer_with_invalid_tags(self, scholarship_data):
        """Test serializer validation with invalid tags data"""
        scholarship_data['tag_ids'] = [-1]  # Invalid tag ID
        
        serializer = ScholarshipCreateSerializer(data=scholarship_data)
        assert not serializer.is_valid()
        assert 'tag_ids' in serializer.errors

    def test_create_serializer_with_invalid_amount_format(self, scholarship_data):
        """Test serializer validation with invalid amount format"""
        scholarship_data['amount'] = 'not-a-number'
        
        serializer = ScholarshipCreateSerializer(data=scholarship_data)
        assert not serializer.is_valid()
        assert 'amount' in serializer.errors

    def test_create_serializer_with_invalid_title_length(self, scholarship_data):
        """Test serializer validation with too long title"""
        scholarship_data['title'] = 'x' * 201  # Exceeds max_length=200
        
        serializer = ScholarshipCreateSerializer(data=scholarship_data)
        assert not serializer.is_valid()
        assert 'title' in serializer.errors 