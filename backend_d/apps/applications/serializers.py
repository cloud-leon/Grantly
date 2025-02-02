from rest_framework import serializers
from .models import Application
from apps.scholarships.serializers import ScholarshipListSerializer
from apps.scholarships.models import Scholarship
from django.core.exceptions import ValidationError

class ApplicationListSerializer(serializers.ModelSerializer):
    scholarship = ScholarshipListSerializer(read_only=True)

    class Meta:
        model = Application
        fields = [
            'id',
            'scholarship',
            'status',
            'swipe_status',
            'created_at',
            'updated_at',
            'submitted_at'
        ]
        read_only_fields = ['status', 'submitted_at']

class ApplicationDetailSerializer(serializers.ModelSerializer):
    scholarship = ScholarshipListSerializer(read_only=True)

    class Meta:
        model = Application
        fields = [
            'id',
            'scholarship',
            'status',
            'swipe_status',
            'answers',
            'documents',
            'created_at',
            'updated_at',
            'submitted_at'
        ]
        read_only_fields = ['submitted_at']

class SwipeSerializer(serializers.Serializer):
    scholarship_id = serializers.IntegerField()
    swipe_direction = serializers.ChoiceField(choices=['left', 'right', 'saved'])

    def validate_scholarship_id(self, value):
        """
        Check that the scholarship exists.
        """
        try:
            Scholarship.objects.get(id=value)
        except Scholarship.DoesNotExist:
            raise serializers.ValidationError("Scholarship does not exist")
        return value

    def create(self, validated_data):
        user = self.context['request'].user
        scholarship_id = validated_data['scholarship_id']
        swipe_direction = validated_data['swipe_direction']

        application, created = Application.objects.get_or_create(
            user=user,
            scholarship_id=scholarship_id,
            defaults={'swipe_status': swipe_direction}
        )

        if not created:
            application.swipe_status = swipe_direction
            application.save()

        return application 