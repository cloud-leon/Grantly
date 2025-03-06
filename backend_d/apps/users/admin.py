from django.contrib import admin
from .models import User, UserProfile

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('email', 'phone_number', 'is_active')
    search_fields = ('email', 'phone_number')

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('firebase_uid', 'first_name', 'last_name')
    search_fields = ('firebase_uid', 'first_name', 'last_name')
