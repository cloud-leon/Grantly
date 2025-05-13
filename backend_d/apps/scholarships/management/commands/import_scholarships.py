import csv
from django.core.management.base import BaseCommand
from apps.scholarships.models import Scholarship, ScholarshipTag
from datetime import datetime
import re
import calendar

class Command(BaseCommand):
    help = 'Import scholarships from CSV file'

    def add_arguments(self, parser):
        parser.add_argument('csv_file', type=str, help='Path to CSV file')

    def extract_tags(self, scholarship_data):
        """Extract tags from scholarship data based on keywords"""
        tags = set()
        
        # Level of Study tags
        level_keywords = {
            'undergraduate': ['undergraduate', 'bachelor', 'college'],
            'graduate': ['graduate', 'master', 'phd', 'doctoral'],
            'high school': ['high school', 'highschool'],
        }
        
        # Amount-based tags
        try:
            amount = float(re.sub(r'[^\d.]', '', scholarship_data['Award Amount']))
            if amount >= 10000:
                tags.add('Full Ride')
            elif amount >= 5000:
                tags.add('Major Award')
            else:
                tags.add('Minor Award')
        except:
            tags.add('Variable Amount')

        # Focus area tags
        focus_keywords = {
            'STEM': ['science', 'technology', 'engineering', 'mathematics', 'stem', 'computer'],
            'Arts': ['art', 'music', 'theater', 'creative', 'performance'],
            'Business': ['business', 'entrepreneurship', 'finance', 'economics'],
            'Healthcare': ['medical', 'nursing', 'healthcare', 'medicine'],
            'Education': ['teaching', 'education', 'teacher'],
        }

        # Merit vs Need-based tags
        merit_keywords = ['merit', 'academic', 'achievement', 'gpa', 'score']
        need_keywords = ['need', 'financial', 'income', 'economic']

        # Add level of study tags
        for tag, keywords in level_keywords.items():
            if any(keyword in scholarship_data['Level of Study'].lower() for keyword in keywords):
                tags.add(tag.title())

        # Add focus area tags
        for tag, keywords in focus_keywords.items():
            text_to_search = f"{scholarship_data['Focus']} {scholarship_data['Purpose']}".lower()
            if any(keyword in text_to_search for keyword in keywords):
                tags.add(tag)

        # Add merit/need based tags
        text_to_search = f"{scholarship_data['Criteria']} {scholarship_data['Qualifications']}".lower()
        if any(keyword in text_to_search for keyword in merit_keywords):
            tags.add('Merit-based')
        if any(keyword in text_to_search for keyword in need_keywords):
            tags.add('Need-based')

        # Add deadline-based tags
        try:
            deadline = datetime.strptime(scholarship_data['Deadline'], '%Y-%m-%d')
            if (deadline - datetime.now()).days <= 30:
                tags.add('Urgent')
        except:
            pass

        return list(tags)

    def clean_amount(self, amount_str):
        """Clean and convert amount string to decimal or return 0"""
        if not amount_str or amount_str.strip() == 'N/A':
            return '0'
        
        # Remove any non-numeric characters except decimal point
        amount_str = amount_str.strip()
        if amount_str.startswith('$'):
            amount_str = amount_str[1:]
        
        # Handle ranges by taking the higher amount
        if '  ' in amount_str:  # Double space indicates range in your CSV
            amounts = amount_str.split('  ')
            amount_str = max(amounts, key=lambda x: float(''.join(c for c in x if c.isdigit() or c == '.')))
        
        # Extract first number if multiple exist
        amount_str = ''.join(c for c in amount_str if c.isdigit() or c == '.')
        
        return amount_str if amount_str else '0'

    def clean_deadline(self, deadline_str):
        """Clean and convert deadline string to date or return a default date"""
        if not deadline_str or deadline_str.strip() == 'N/A':
            # Set default deadline to end of current year
            return datetime(datetime.now().year, 12, 31).date()
        
        try:
            # Try parsing common date formats
            for fmt in ['%Y-%m-%d', '%B', '%b']:
                try:
                    date = datetime.strptime(deadline_str.strip(), fmt)
                    # If only month is provided, set to last day of that month in current year
                    if fmt in ['%B', '%b']:
                        year = datetime.now().year
                        month = date.month
                        _, last_day = calendar.monthrange(year, month)
                        date = datetime(year, month, last_day)
                    return date.date()
                except ValueError:
                    continue
            
            # If no format matches, return end of year
            return datetime(datetime.now().year, 12, 31).date()
        except:
            return datetime(datetime.now().year, 12, 31).date()

    def handle(self, *args, **options):
        csv_file = options['csv_file']
        created_count = 0
        updated_count = 0

        with open(csv_file, 'r') as file:
            reader = csv.DictReader(file)
            for row in reader:
                try:
                    # Extract tags
                    tags = self.extract_tags(row)
                    
                    # Create or get tag objects
                    tag_objects = []
                    for tag_name in tags:
                        tag, _ = ScholarshipTag.objects.get_or_create(name=tag_name)
                        tag_objects.append(tag)

                    # Clean amount
                    amount = self.clean_amount(row['Award Amount'])

                    # Clean deadline
                    deadline = self.clean_deadline(row['Deadline'])

                    # Build rich description
                    description_parts = [
                        f"Organization: {row['Organization']}",
                        f"Purpose: {row['Purpose']}" if row['Purpose'] and row['Purpose'] != 'N/A' else None,
                        f"Award Type: {row['Award Type']}" if row['Award Type'] and row['Award Type'] != 'N/A' else None,
                        f"Duration: {row['Duration']}" if row['Duration'] and row['Duration'] != 'N/A' else None,
                        f"Number of Awards: {row['Number of Awards']}" if row['Number of Awards'] and row['Number of Awards'] != 'N/A' else None,
                        f"Contact: {row['Contact']}" if row['Contact'] and row['Contact'] != 'N/A' else None,
                        f"More Info: {row['More Info']}" if row['More Info'] and row['More Info'] != 'N/A' else None,
                        f"Location: {row['location'] if 'location' in row else 'United States'}"
                    ]
                    description = '\n\n'.join(filter(None, description_parts))

                    # Build eligibility criteria
                    criteria_parts = [
                        f"Qualifications: {row['Qualifications']}" if row['Qualifications'] and row['Qualifications'] != 'N/A' else None,
                        f"Criteria: {row['Criteria']}" if row['Criteria'] and row['Criteria'] != 'N/A' else None,
                        f"How to Apply: {row['To Apply']}" if row['To Apply'] and row['To Apply'] != 'N/A' else None
                    ]
                    eligibility_criteria = '\n\n'.join(filter(None, criteria_parts))

                    # Create or update scholarship
                    scholarship, created = Scholarship.objects.update_or_create(
                        title=row['Scholarship Name'],
                        defaults={
                            'description': description,
                            'amount': amount,
                            'deadline': deadline,
                            'education_level': row['Level of Study'] if row['Level of Study'] and row['Level of Study'] != 'N/A' else '',
                            'field_of_study': row['Focus'] if row['Focus'] and row['Focus'] != 'N/A' else '',
                            'eligibility_criteria': eligibility_criteria,
                            'is_active': True,
                            'created_at': datetime.now(),
                            'updated_at': datetime.now(),
                        }
                    )

                    # Set tags
                    scholarship.tags.set(tag_objects)

                    if created:
                        created_count += 1
                    else:
                        updated_count += 1

                except Exception as e:
                    self.stdout.write(
                        self.style.ERROR(
                            f'Error processing scholarship {row["Scholarship Name"]}: {str(e)}'
                        )
                    )
                    continue

            self.stdout.write(
                self.style.SUCCESS(
                    f'Successfully imported {created_count} new scholarships and updated {updated_count} existing ones'
                )
            ) 