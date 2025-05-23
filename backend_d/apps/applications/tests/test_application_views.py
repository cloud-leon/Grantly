import pytest
from django.urls import reverse
from rest_framework import status
from django.utils import timezone
from apps.applications.models import Application
from django.utils.timezone import timedelta
from apps.scholarships.models import Scholarship

pytestmark = pytest.mark.django_db

@pytest.mark.django_db
class TestApplicationViewSet:
    @pytest.fixture(autouse=True)
    def setup(self, api_client):
        self.client = api_client
        self.url = reverse('applications:application-list')

    def test_list_applications_unauthorized(self, api_client):
        """Test that unauthenticated users can't list applications"""
        response = api_client.get(self.url)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    @pytest.fixture
    def application(self, test_user, active_scholarship):
        """Create a test application"""
        return Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            status='pending',
            swipe_status='right'
        )

    def test_list_applications(self, auth_client, application):
        response = auth_client.get(self.url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1
        assert response.data[0]['id'] == application.id

    def test_retrieve_application(self, auth_client, application):
        url = reverse('applications:application-detail', kwargs={'pk': application.id})
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['id'] == application.id
        assert 'answers' in response.data
        assert 'documents' in response.data

    def test_swipe_right(self, auth_client, active_scholarship):
        url = reverse('applications:application-swipe')
        data = {
            'scholarship_id': active_scholarship.id,
            'swipe_direction': 'right'
        }
        response = auth_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['swipe_status'] == 'right'

    def test_swipe_left(self, auth_client, active_scholarship):
        url = reverse('applications:application-swipe')
        data = {
            'scholarship_id': active_scholarship.id,
            'swipe_direction': 'left'
        }
        response = auth_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['swipe_status'] == 'left'

    def test_swipe_invalid(self, auth_client, active_scholarship):
        """Test invalid swipe direction"""
        url = reverse('applications:application-swipe')
        data = {
            'scholarship_id': active_scholarship.id,
            'swipe_direction': 'invalid'
        }
        response = auth_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_interested_list(self, auth_client, application):
        url = reverse('applications:application-interested')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 1

    def test_saved_list(self, auth_client, test_user, active_scholarship):
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            swipe_status='saved'
        )
        url = reverse('applications:application-saved')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 1

    def test_filter_by_status(self, auth_client, application):
        url = reverse('applications:application-list')
        response = auth_client.get(f"{url}?status=pending")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1

        response = auth_client.get(f"{url}?status=accepted")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 0

    def test_filter_by_swipe_status(self, auth_client, application):
        url = reverse('applications:application-list')
        response = auth_client.get(f"{url}?swipe_status=right")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1

        response = auth_client.get(f"{url}?swipe_status=left")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 0

    def test_search_by_scholarship(self, auth_client, application):
        url = reverse('applications:application-list')
        response = auth_client.get(f"{url}?search=Test")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1

        response = auth_client.get(f"{url}?search=NonExistent")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 0

    def test_ordering(self, auth_client, test_user, active_scholarship):
        # Create another scholarship
        scholarship2 = Scholarship.objects.create(
            title='Second Scholarship',
            description='Test Description',
            amount=3000.00,
            deadline=timezone.now().date() + timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True
        )

        # Create applications with different dates
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            created_at=timezone.now() - timezone.timedelta(days=1)
        )
        Application.objects.create(
            user=test_user,
            scholarship=scholarship2,  # Use different scholarship
            created_at=timezone.now()
        )

        url = reverse('applications:application-list')
        response = auth_client.get(f"{url}?ordering=-created_at")
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 2
        dates = [item['created_at'] for item in response.data]
        assert dates[0] > dates[1]

    def test_applied_list(self, auth_client, test_user, active_scholarship):
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            status='submitted'
        )
        url = reverse('applications:application-applied')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 1

    def test_pending_list(self, auth_client, test_user, active_scholarship):
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            status='pending'
        )
        url = reverse('applications:application-pending')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 1

    def test_accepted_list(self, auth_client, test_user, active_scholarship):
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            status='accepted'
        )
        url = reverse('applications:application-accepted')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 1

    def test_rejected_list(self, auth_client, test_user, active_scholarship):
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            status='rejected'
        )
        url = reverse('applications:application-rejected')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) == 1

    def test_stats(self, auth_client, test_user, active_scholarship):
        # Create multiple scholarships for different statuses
        scholarship2 = Scholarship.objects.create(
            title='Second Scholarship',
            description='Test Description',
            amount=3000.00,
            deadline=timezone.now().date() + timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True
        )
        scholarship3 = Scholarship.objects.create(
            title='Third Scholarship',
            description='Test Description',
            amount=2000.00,
            deadline=timezone.now().date() + timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True
        )
        scholarship4 = Scholarship.objects.create(
            title='Fourth Scholarship',
            description='Test Description',
            amount=1000.00,
            deadline=timezone.now().date() + timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True
        )

        # Create applications with different statuses using different scholarships
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            status='submitted'
        )
        Application.objects.create(
            user=test_user,
            scholarship=scholarship2,
            status='pending'
        )
        Application.objects.create(
            user=test_user,
            scholarship=scholarship3,
            status='accepted'
        )
        Application.objects.create(
            user=test_user,
            scholarship=scholarship4,
            status='',  # Set empty status for swipe-only applications
            swipe_status='right'
        )

        url = reverse('applications:application-stats')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['total'] == 4
        assert response.data['applied'] == 2  # submitted + accepted
        assert response.data['pending'] == 1
        assert response.data['accepted'] == 1
        assert response.data['interested'] == 1

    def test_applied_list_with_count(self, auth_client, test_user, active_scholarship):
        Application.objects.create(
            user=test_user,
            scholarship=active_scholarship,
            status='submitted'
        )
        url = reverse('applications:application-applied')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['count'] == 1
        assert len(response.data['results']) == 1 