from django.urls import path
from . import views
from rest_framework_simplejwt.views import TokenRefreshView
from .views import ProfileCreateView, ProfileUpdateView

app_name = 'users_auth'

urlpatterns = [
    path('auth/register/', views.RegisterView.as_view(), name='register'),
    path('auth/login/', views.LoginView.as_view(), name='login'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('auth/protected/', views.ProtectedView.as_view(), name='protected-endpoint'),
    path('profile/', views.ProfileViewSet.as_view({
        'get': 'retrieve',
        'put': 'update',
        'patch': 'partial_update'
    }), name='profile'),
    path('profile/create/', views.ProfileViewSet.as_view({'post': 'create'}), name='profile-create'),
    path('auth/password/reset/', views.PasswordResetView.as_view(), name='password-reset'),
    path('auth/password/reset/confirm/<str:uidb64>/<str:token>/', 
         views.PasswordResetConfirmView.as_view(), 
         name='password-reset-confirm'),
    path('auth/social/google/', views.GoogleAuthView.as_view(), name='google-auth'),
    path('auth/social/apple/', views.AppleAuthView.as_view(), name='apple-auth'),
    path('health/', views.health_check, name='health-check'),
    path('profile/v2/', views.ProfileViewSet.as_view({
        'get': 'retrieve',
        'put': 'update',
        'patch': 'partial_update'
    }), name='profile-v2'),
    path('profile/update/<int:pk>/', views.ProfileUpdateView.as_view(), name='profile-update'),
    path('auth/phone/', views.PhoneAuthView.as_view(), name='phone-auth'),
    path('auth/phone/verify/', views.VerifyPhoneView.as_view(), name='verify-phone'),
]

