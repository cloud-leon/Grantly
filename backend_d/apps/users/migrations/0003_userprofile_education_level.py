# Generated by Django 4.2.10 on 2025-02-28 05:00

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("users", "0002_rename_dob_userprofile_date_of_birth_userprofile_bio_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="userprofile",
            name="education_level",
            field=models.CharField(
                blank=True,
                choices=[
                    ("undergraduate", "Undergraduate"),
                    ("graduate", "Graduate"),
                    ("high_school", "High School"),
                ],
                max_length=20,
                null=True,
            ),
        ),
    ]
