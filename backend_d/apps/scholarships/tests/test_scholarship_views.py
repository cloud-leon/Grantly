import pytest
from django.urls import reverse
from rest_framework import status
from django.utils import timezone
from datetime import timedelta

pytestmark = pytest.mark.django_db

@pytest.fixture
def admin_client(auth_client, test_user):
    """Returns an authenticated admin client"""
    test_user.is_staff = True
    test_user.is_superuser = True
    test_user.save()
    auth_client.force_authenticate(user=test_user)  # Re-authenticate after changes
    return auth_client

@pytest.mark.django_db
class TestScholarshipViewSet:
    @pytest.fixture(autouse=True)
    def setup(self, api_client):
        self.client = api_client

    def test_list_scholarships(self, api_client, active_scholarship):
        """List should work without authentication"""
        url = reverse('scholarships:scholarship-list')
        response = api_client.get(url, format='json')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1

    def test_create_scholarship(self, admin_client, scholarship_tag):
        """Create requires admin authentication"""
        url = reverse('scholarships:scholarship-list')
        data = {
            'title': 'New Scholarship',
            'description': 'New Description',
            'amount': '2500.00',
            'deadline': (timezone.now().date() + timedelta(days=30)).isoformat(),
            'eligibility_criteria': 'New Criteria',
            'tag_ids': [scholarship_tag.id]
        }
        response = admin_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['title'] == 'New Scholarship'

    def test_filter_by_tag(self, api_client, active_scholarship, scholarship_tag):
        url = reverse('scholarships:scholarship-list')
        response = api_client.get(
            f"{url}?tags__name={scholarship_tag.name}",
            format='json'
        )
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1

    def test_search_scholarship(self, api_client, active_scholarship):
        url = reverse('scholarships:scholarship-list')
        response = api_client.get(f"{url}?search=Test", format='json')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1

    def test_filter_expired(self, api_client, active_scholarship, expired_scholarship):
        url = reverse('scholarships:scholarship-list')
        response = api_client.get(f"{url}?show_expired=true", format='json')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 2

        response = api_client.get(url)  # Default: don't show expired
        assert len(response.data) == 1

@pytest.mark.django_db
class TestScholarshipTagViewSet:
    def test_list_tags(self, api_client, scholarship_tag):
        """List should work without authentication"""
        url = reverse('scholarships:scholarship-tag-list')
        response = api_client.get(url, format='json')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1

    def test_create_tag(self, admin_client):
        """Create requires admin authentication"""
        url = reverse('scholarships:scholarship-tag-list')
        data = {
            'name': 'Science',
            'description': 'Science scholarships'
        }
        response = admin_client.post(url, data, format='json')
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['name'] == 'Science'
        assert response.data['slug'] == 'science'

    def test_search_tags(self, api_client, scholarship_tag):
        url = reverse('scholarships:scholarship-tag-list')
        response = api_client.get(f"{url}?search=Engineering", format='json')
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1 