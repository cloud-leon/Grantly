from django.db.models import F, ExpressionWrapper, FloatField, Func
from django.db.models.functions import Cast, Random
from django.contrib.postgres.search import TrigramSimilarity
from apps.users.models.profile import Profile
from django.db.models import Q
from django.core.paginator import Paginator
from django.db.models import QuerySet

class ScholarshipMatcher:
    def __init__(self, user_profile):
        self.profile = user_profile
        self.weights = {
            'tag_match': 0.40,
            'education_match': 0.30,
            'field_match': 0.20,
            'random_factor': 0.10  # Add randomization weight
        }

    def get_matched_scholarships(
        self, 
        queryset: QuerySet, 
        page: int = 1, 
        page_size: int = 10
    ) -> QuerySet:
        """
        Get matched scholarships with pagination support.
        
        Args:
            queryset: Base scholarship queryset to filter from
            page: Page number (1-based)
            page_size: Number of items per page
            
        Returns:
            Paginated queryset of matched scholarships
        """
        # First apply any filtering/matching logic
        matched_scholarships = self._apply_matching_criteria(queryset)
        
        # Then paginate the results
        paginator = Paginator(matched_scholarships, page_size)
        paginated_scholarships = paginator.get_page(page)
        
        return paginated_scholarships

    def _apply_matching_criteria(self, queryset: QuerySet) -> QuerySet:
        """
        Apply the matching criteria to the queryset.
        This is where your existing matching logic should go.
        """
        scored_scholarships = queryset.annotate(
            match_score=self._calculate_match_score(),
            random_score=Random()  # Add random score
        ).order_by('-match_score', '-random_score')
        
        return scored_scholarships

    def _calculate_match_score(self):
        """
        Calculates the weighted match score using all criteria plus randomization
        """
        return ExpressionWrapper(
            (self._tag_match_score() * self.weights['tag_match']) +
            (self._education_match_score() * self.weights['education_match']) +
            (self._field_match_score() * self.weights['field_match']) +
            (Random() * self.weights['random_factor']),  # Add random factor
            output_field=FloatField()
        )

    def _tag_match_score(self):
        """
        Calculates score based on matching tags between user interests and scholarship
        """
        user_interests = self.profile.interests
        return ExpressionWrapper(
            Cast(
                Q(tags__name__in=user_interests),  # Use Q instead of F().in_
                output_field=FloatField()
            ),
            output_field=FloatField()
        )

    def _education_match_score(self):
        """
        Score based on education level match
        """
        user_education = self.profile.education_level
        return Cast(
            Q(education_level=user_education),  # Use Q instead of F().eq
            output_field=FloatField()
        )

    def _field_match_score(self):
        """
        Score based on field of study similarity
        """
        user_field = self.profile.field_of_study
        return TrigramSimilarity('field_of_study', user_field)

    def _amount_range_score(self):
        """
        Score based on whether scholarship amount is in user's preferred range
        """
        min_amount = self.profile.min_amount or 0
        max_amount = self.profile.max_amount or float('inf')
        
        return ExpressionWrapper(
            Cast(F('amount') >= min_amount, FloatField()) *
            Cast(F('amount') <= max_amount, FloatField()),
            output_field=FloatField()
        )

    def _location_match_score(self):
        """
        Score based on location match if applicable
        """
        user_location = self.profile.location
        return Cast(F('location') == user_location, FloatField()) 