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

# Create your views here.

class ScholarshipViewSet(viewsets.ModelViewSet):
    queryset = Scholarship.objects.all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = {
        'tags__name': ['exact', 'in'],
        'amount': ['gte', 'lte'],
        'deadline': ['gte', 'lte'],
        'is_active': ['exact'],
    }
    search_fields = ['title', 'description', 'eligibility_criteria']
    ordering_fields = ['created_at', 'deadline', 'amount']
    ordering = ['-created_at']  # Default ordering
    
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

    def get_queryset(self):
        queryset = super().get_queryset()
        # Add custom filtering for expired scholarships
        show_expired = self.request.query_params.get('show_expired', 'false').lower()
        if show_expired != 'true':
            from django.utils import timezone
            queryset = queryset.filter(deadline__gte=timezone.now().date())
        return queryset

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
