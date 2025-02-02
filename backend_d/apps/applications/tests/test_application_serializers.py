import pytest
from apps.applications.serializers import (
    ApplicationListSerializer,
    ApplicationDetailSerializer,
    SwipeSerializer
)
from apps.applications.models import Application
import django.db.utils

pytestmark = pytest.mark.django_db

class TestApplicationSerializers:
    def test_list_serializer(self, application):
        serializer = ApplicationListSerializer(application)
        data = serializer.data
        assert data['status'] == 'pending'
        assert data['swipe_status'] == 'right'
        assert 'scholarship' in data
        assert 'answers' not in data
        assert 'documents' not in data

    def test_detail_serializer(self, application):
        serializer = ApplicationDetailSerializer(application)
        data = serializer.data
        assert data['status'] == 'pending'
        assert data['swipe_status'] == 'right'
        assert 'scholarship' in data
        assert 'answers' in data
        assert 'documents' in data

    def test_swipe_serializer_valid(self, test_user, active_scholarship):
        data = {
            'scholarship_id': active_scholarship.id,
            'swipe_direction': 'right'
        }
        context = {'request': type('Request', (), {'user': test_user})}
        serializer = SwipeSerializer(data=data, context=context)
        assert serializer.is_valid()
        application = serializer.save()
        assert application.swipe_status == 'right'

    def test_swipe_serializer_invalid_direction(self, test_user, active_scholarship):
        data = {
            'scholarship_id': active_scholarship.id,
            'swipe_direction': 'invalid'
        }
        context = {'request': type('Request', (), {'user': test_user})}
        serializer = SwipeSerializer(data=data, context=context)
        assert not serializer.is_valid()
        assert 'swipe_direction' in serializer.errors

    def test_swipe_serializer_invalid_scholarship(self, test_user):
        data = {
            'scholarship_id': 99999,  # Non-existent scholarship
            'swipe_direction': 'right'
        }
        context = {'request': type('Request', (), {'user': test_user})}
        serializer = SwipeSerializer(data=data, context=context)
        assert not serializer.is_valid()
        assert 'scholarship_id' in serializer.errors

    def test_swipe_serializer_update_existing(self, test_user, active_scholarship):
        # Create initial application
        application = Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            swipe_status='left'
        )

        # Update via serializer
        data = {
            'scholarship_id': active_scholarship.id,
            'swipe_direction': 'right'
        }
        context = {'request': type('Request', (), {'user': test_user})}
        serializer = SwipeSerializer(data=data, context=context)
        assert serializer.is_valid()
        updated_application = serializer.save()
        
        # Check it updated the existing one
        assert updated_application.id == application.id
        assert updated_application.swipe_status == 'right' 