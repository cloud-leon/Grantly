from django.contrib import admin
from .models import Scholarship, ScholarshipTag

@admin.register(ScholarshipTag)
class ScholarshipTagAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'created_at', 'get_scholarships_count')
    search_fields = ('name', 'description')
    prepopulated_fields = {'slug': ('name',)}

@admin.register(Scholarship)
class ScholarshipAdmin(admin.ModelAdmin):
    list_display = ('title', 'amount', 'deadline', 'is_active', 'is_expired')
    list_filter = ('is_active', 'tags', 'created_at')
    search_fields = ('title', 'description', 'eligibility_criteria')
    filter_horizontal = ('tags',)
    readonly_fields = ('created_at', 'updated_at')
