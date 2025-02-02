from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

app_name = 'scholarships'

router = DefaultRouter()
router.register(r'scholarships', views.ScholarshipViewSet, basename='scholarship')
router.register(r'tags', views.ScholarshipTagViewSet, basename='scholarship-tag')

urlpatterns = [
    path('', include(router.urls)),
] 