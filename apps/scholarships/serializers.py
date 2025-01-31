from rest_framework import serializers
from .models import Scholarship, ScholarshipTag

class ScholarshipTagSerializer(serializers.ModelSerializer):
    scholarship_count = serializers.SerializerMethodField()

    class Meta:
        model = ScholarshipTag
        fields = ['id', 'name', 'slug', 'description', 'created_at', 'scholarship_count']
        read_only_fields = ['slug', 'created_at', 'scholarship_count']

    def get_scholarship_count(self, obj):
        return obj.get_scholarships_count()

class ScholarshipListSerializer(serializers.ModelSerializer):
    tags = ScholarshipTagSerializer(many=True, read_only=True)
    is_expired = serializers.BooleanField(read_only=True)

    class Meta:
        model = Scholarship
        fields = [
            'id', 
            'title', 
            'amount', 
            'deadline', 
            'tags', 
            'is_active',
            'is_expired',
            'created_at'
        ]
        read_only_fields = ['created_at']

class ScholarshipDetailSerializer(serializers.ModelSerializer):
    tags = ScholarshipTagSerializer(many=True, read_only=True)
    tag_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        write_only=True,
        queryset=ScholarshipTag.objects.all(),
        source='tags',
        required=False
    )
    is_expired = serializers.BooleanField(read_only=True)

    class Meta:
        model = Scholarship
        fields = [
            'id',
            'title',
            'description',
            'amount',
            'deadline',
            'eligibility_criteria',
            'tags',
            'tag_ids',
            'is_active',
            'is_expired',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']

    def validate_deadline(self, value):
        """Validate that deadline is not in the past"""
        from django.utils import timezone
        if value < timezone.now().date():
            raise serializers.ValidationError("Deadline cannot be in the past")
        return value

    def validate_amount(self, value):
        """Validate scholarship amount"""
        if value <= 0:
            raise serializers.ValidationError("Amount must be greater than 0")
        return value

class ScholarshipCreateSerializer(ScholarshipDetailSerializer):
    class Meta(ScholarshipDetailSerializer.Meta):
        read_only_fields = ['created_at', 'updated_at', 'is_active']

    def create(self, validated_data):
        tags = validated_data.pop('tags', [])
        scholarship = Scholarship.objects.create(**validated_data)
        if tags:
            scholarship.tags.set(tags)
        return scholarship

class ScholarshipUpdateSerializer(ScholarshipDetailSerializer):
    class Meta(ScholarshipDetailSerializer.Meta):
        read_only_fields = ['created_at', 'updated_at']

    def update(self, instance, validated_data):
        tags = validated_data.pop('tags', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        if tags is not None:
            instance.tags.set(tags)
        return instance 