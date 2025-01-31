from django.urls import path
from . import views
from rest_framework_simplejwt.views import TokenRefreshView

app_name = 'users'

urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('protected/', views.ProtectedView.as_view(), name='protected-endpoint'),
    path('password/reset/', views.PasswordResetView.as_view(), name='password-reset'),
    path('password/reset/confirm/<str:uidb64>/<str:token>/', 
         views.PasswordResetConfirmView.as_view(), 
         name='password-reset-confirm'),
    path('profile/', views.UserProfileView.as_view(), name='profile'),
    path('profile/v2/', views.ProfileViewSet.as_view({
        'get': 'retrieve',
        'put': 'update',
        'patch': 'partial_update'
    }), name='profile-v2'),
    path('auth/google/', views.GoogleAuthView.as_view(), name='google-auth'),
    path('auth/apple/', views.AppleAuthView.as_view(), name='apple-auth'),
    path('auth/phone/', views.PhoneAuthView.as_view(), name='phone-auth'),
    path('auth/phone/verify/', views.VerifyPhoneView.as_view(), name='verify-phone'),
]

