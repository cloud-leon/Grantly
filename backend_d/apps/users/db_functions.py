from django.db.models import Func
from django.db import migrations
from datetime import datetime

def create_update_grade_level_function():
    return """
    CREATE OR REPLACE FUNCTION update_class_years() RETURNS VOID AS $$
    DECLARE
        current_year INT := EXTRACT(YEAR FROM CURRENT_DATE);
    BEGIN
        UPDATE user_profiles
        SET grade_level = 
            CASE 
                WHEN grade_level LIKE 'High School Freshman%' THEN 'High School Sophomore (Class of ' || (current_year + 2) || ')'
                WHEN grade_level LIKE 'High School Sophomore%' THEN 'High School Junior (Class of ' || (current_year + 1) || ')'
                WHEN grade_level LIKE 'High School Junior%' THEN 'High School Senior (Class of ' || current_year || ')'
                WHEN grade_level LIKE 'High School Senior%' THEN 'College Freshman (Class of ' || (current_year + 4) || ')'
                WHEN grade_level LIKE 'College Freshman%' THEN 'College Sophomore (Class of ' || (current_year + 3) || ')'
                WHEN grade_level LIKE 'College Sophomore%' THEN 'College Junior (Class of ' || (current_year + 2) || ')'
                WHEN grade_level LIKE 'College Junior%' THEN 'College Senior (Class of ' || (current_year + 1) || ')'
                WHEN grade_level LIKE 'College Senior%' THEN 'Graduate School 1st Year'
                WHEN grade_level LIKE 'Graduate School 1st Year' THEN 'Graduate School 2nd Year'
                WHEN grade_level LIKE 'Graduate School 2nd Year' THEN 'Graduate School 3rd Year'
                WHEN grade_level LIKE 'Graduate School 3rd Year' THEN 'Graduate School 4th Year'
                ELSE grade_level
            END;
    END;
    $$ LANGUAGE plpgsql;
    """ 