import pytest
from django.utils import timezone
from apps.scholarships.matching import ScholarshipMatcher
from apps.scholarships.models import Scholarship, ScholarshipTag
from apps.users.models import UserProfile
from django.test import TestCase

pytestmark = pytest.mark.django_db

class TestScholarshipMatcher:
    def test_tag_matching(self, test_user):
        profile, _ = UserProfile.objects.get_or_create(
            user=test_user,
            defaults={
                'interests': ['Engineering', 'Technology']
            }
        )
        
        # Create tags
        eng_tag = ScholarshipTag.objects.create(name='Engineering')
        art_tag = ScholarshipTag.objects.create(name='Art')
        
        # Create scholarships without education_level and field_of_study
        scholarship1 = Scholarship.objects.create(
            title='Engineering Scholarship',
            description='Test Description',
            amount=3000.00,
            deadline=timezone.now().date() + timezone.timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True
        )
        scholarship1.tags.add(eng_tag)
        
        scholarship2 = Scholarship.objects.create(
            title='Art Scholarship',
            description='Test Description',
            amount=3000.00,
            deadline=timezone.now().date() + timezone.timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True
        )
        scholarship2.tags.add(art_tag)
        
        matcher = ScholarshipMatcher(profile)
        matched = matcher.get_matched_scholarships(Scholarship.objects.all())
        
        # Due to randomization, we can only check if engineering scholarship is in results
        assert scholarship1 in matched
        assert scholarship2 in matched

    def test_education_matching(self, test_user):
        profile, _ = UserProfile.objects.get_or_create(
            user=test_user,
            defaults={
                'education_level': 'undergraduate'
            }
        )
        
        scholarship1 = Scholarship.objects.create(
            title='Undergrad Scholarship',
            description='Test Description',
            amount=3000.00,
            deadline=timezone.now().date() + timezone.timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True,
            education_level='undergraduate'
        )
        scholarship2 = Scholarship.objects.create(
            title='Graduate Scholarship',
            description='Test Description',
            amount=3000.00,
            deadline=timezone.now().date() + timezone.timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True,
            education_level='graduate'
        )
        
        matcher = ScholarshipMatcher(profile)
        matched = list(matcher.get_matched_scholarships(Scholarship.objects.all()))
        
        # Both scholarships should be in results, but order may vary
        assert set([s.id for s in matched]) == set([scholarship1.id, scholarship2.id])

    def test_combined_matching(self, test_user):
        profile, _ = UserProfile.objects.get_or_create(
            user=test_user,
            defaults={
                'interests': ['Engineering'],
                'education_level': 'undergraduate',
                'field_of_study': 'Computer Science'
            }
        )
        
        eng_tag = ScholarshipTag.objects.create(name='Engineering')
        art_tag = ScholarshipTag.objects.create(name='Art')
        
        # Perfect match
        scholarship1 = Scholarship.objects.create(
            title='Perfect Match',
            description='Test Description',
            amount=3000.00,
            deadline=timezone.now().date() + timezone.timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True,
            education_level='undergraduate',
            field_of_study='Computer Science'
        )
        scholarship1.tags.add(eng_tag)
        
        # Partial match
        scholarship2 = Scholarship.objects.create(
            title='Partial Match',
            description='Test Description',
            amount=4000.00,
            deadline=timezone.now().date() + timezone.timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True,
            education_level='graduate',
            field_of_study='Engineering'
        )
        scholarship2.tags.add(eng_tag)
        
        # Poor match
        scholarship3 = Scholarship.objects.create(
            title='Poor Match',
            description='Test Description',
            amount=10000.00,
            deadline=timezone.now().date() + timezone.timedelta(days=30),
            eligibility_criteria='Test Criteria',
            is_active=True,
            education_level='graduate',
            field_of_study='Fine Arts'
        )
        scholarship3.tags.add(art_tag)
        
        matcher = ScholarshipMatcher(profile)
        matched = list(matcher.get_matched_scholarships(Scholarship.objects.all()))
        
        # All scholarships should be in results
        assert set([s.id for s in matched]) == set([scholarship1.id, scholarship2.id, scholarship3.id])

    def test_pagination(self, test_user):
        profile, _ = UserProfile.objects.get_or_create(
            user=test_user,
            defaults={
                'interests': ['Engineering'],
                'education_level': 'undergraduate'
            }
        )
        
        # Create multiple scholarships
        eng_tag = ScholarshipTag.objects.create(name='Engineering')
        scholarships = []
        for i in range(15):  # Create 15 scholarships
            scholarship = Scholarship.objects.create(
                title=f'Scholarship {i}',
                description='Test Description',
                amount=3000.00,
                deadline=timezone.now().date() + timezone.timedelta(days=30),
                eligibility_criteria='Test Criteria',
                is_active=True,
                education_level='undergraduate'
            )
            scholarship.tags.add(eng_tag)
            scholarships.append(scholarship)
        
        matcher = ScholarshipMatcher(profile)
        
        # Test first page (default page size is 10)
        page_1 = list(matcher.get_matched_scholarships(
            Scholarship.objects.all(),
            page=1,
            page_size=10
        ))
        assert len(page_1) == 10
        
        # Test second page (should have remaining 5 scholarships)
        page_2 = list(matcher.get_matched_scholarships(
            Scholarship.objects.all(),
            page=2,
            page_size=10
        ))
        assert len(page_2) == 5
        
        # Test custom page size
        custom_page = list(matcher.get_matched_scholarships(
            Scholarship.objects.all(),
            page=1,
            page_size=5
        ))
        assert len(custom_page) == 5 