from django.shortcuts import render
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Application
from .serializers import (
    ApplicationListSerializer,
    ApplicationDetailSerializer,
    SwipeSerializer
)

# Create your views here.

class ApplicationViewSet(viewsets.ModelViewSet):
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = {
        'status': ['exact'],
        'swipe_status': ['exact'],
        'created_at': ['gte', 'lte'],
        'scholarship__deadline': ['gte', 'lte']
    }
    search_fields = ['scholarship__title']
    ordering_fields = ['created_at', 'updated_at', 'scholarship__deadline']
    ordering = ['-updated_at']

    def get_queryset(self):
        return Application.objects.filter(user=self.request.user)

    def get_serializer_class(self):
        if self.action == 'list':
            return ApplicationListSerializer
        return ApplicationDetailSerializer

    @action(detail=False)
    def applied(self, request):
        """Get scholarships that have been submitted"""
        queryset = self.get_queryset().filter(
            status__in=['submitted', 'under_review', 'accepted']
        )
        serializer = ApplicationListSerializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False)
    def pending(self, request):
        """Get scholarships that are in draft/pending state"""
        queryset = self.get_queryset().filter(status='pending')
        serializer = ApplicationListSerializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False)
    def accepted(self, request):
        """Get accepted scholarships"""
        queryset = self.get_queryset().filter(status='accepted')
        serializer = ApplicationListSerializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False)
    def rejected(self, request):
        """Get rejected scholarships"""
        queryset = self.get_queryset().filter(status='rejected')
        serializer = ApplicationListSerializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'])
    def swipe(self, request):
        serializer = SwipeSerializer(
            data=request.data,
            context={'request': request}
        )
        if serializer.is_valid():
            application = serializer.save()
            return Response(
                ApplicationListSerializer(application).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False)
    def interested(self, request):
        """Get scholarships user swiped right on"""
        queryset = self.get_queryset().filter(swipe_status='right')
        serializer = ApplicationListSerializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False)
    def saved(self, request):
        """Get scholarships saved for later"""
        queryset = self.get_queryset().filter(swipe_status='saved')
        serializer = ApplicationListSerializer(queryset, many=True)
        return Response(serializer.data)
