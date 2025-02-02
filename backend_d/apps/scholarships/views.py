from django.shortcuts import render
from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticated, AllowAny
from django_filters.rest_framework import DjangoFilterBackend
from .models import Scholarship, ScholarshipTag
from .serializers import (
    ScholarshipListSerializer,
    ScholarshipDetailSerializer,
    ScholarshipCreateSerializer,
    ScholarshipUpdateSerializer,
    ScholarshipTagSerializer
)
from apps.applications.models import Application
from .matching import ScholarshipMatcher
from rest_framework.decorators import action
from rest_framework.response import Response

# Create your views here.

class ScholarshipViewSet(viewsets.ModelViewSet):
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = {
        'tags__name': ['exact', 'in'],
        'amount': ['gte', 'lte'],
        'deadline': ['gte', 'lte'],
        'is_active': ['exact'],
    }
    search_fields = ['title', 'description', 'eligibility_criteria']
    ordering_fields = ['created_at', 'deadline', 'amount']
    ordering = ['-created_at']

    def get_queryset(self):
        queryset = Scholarship.objects.all()
        
        # Filter out swiped scholarships if requested
        exclude_swiped = self.request.query_params.get('exclude_swiped', 'false').lower() == 'true'
        if exclude_swiped and self.request.user.is_authenticated:
            swiped_ids = Application.objects.filter(
                user=self.request.user,
                swipe_status__in=['left', 'right']  # Exclude both left and right swipes
            ).values_list('scholarship_id', flat=True)
            queryset = queryset.exclude(id__in=swiped_ids)

        # Add custom filtering for expired scholarships
        show_expired = self.request.query_params.get('show_expired', 'false').lower()
        if show_expired != 'true':
            from django.utils import timezone
            queryset = queryset.filter(deadline__gte=timezone.now().date())
            
        return queryset

    def get_permissions(self):
        """Allow anyone to list and retrieve scholarships"""
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]

    def get_serializer_class(self):
        if self.action == 'list':
            return ScholarshipListSerializer
        elif self.action == 'create':
            return ScholarshipCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return ScholarshipUpdateSerializer
        return ScholarshipDetailSerializer

    @action(detail=False)
    def matched(self, request):
        """
        Get scholarships matched to user profile
        """
        queryset = self.get_queryset().filter(is_active=True, is_expired=False)
        
        # Get user profile
        profile = request.user.profile
        
        # Use matcher to sort scholarships
        matcher = ScholarshipMatcher(profile)
        matched_scholarships = matcher.get_matched_scholarships(queryset)
        
        page = self.paginate_queryset(matched_scholarships)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(matched_scholarships, many=True)
        return Response({
            'results': serializer.data,
            'count': matched_scholarships.count()
        })

class ScholarshipTagViewSet(viewsets.ModelViewSet):
    queryset = ScholarshipTag.objects.all()
    serializer_class = ScholarshipTagSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'description']

    def get_permissions(self):
        """Allow anyone to list and retrieve tags"""
        if self.action in ['list', 'retrieve']:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
