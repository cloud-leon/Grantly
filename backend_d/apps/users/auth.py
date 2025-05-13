from django.contrib.auth.backends import ModelBackend
from django.db.models import Q

class MultiAuthBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        User = get_user_model()
        
        try:
            # Try to fetch the user by username, email, or phone number
            user = User.objects.get(
                Q(username=username) | 
                Q(email=username) | 
                Q(phone_number=username)
            )
            
            if user.check_password(password):
                return user
            return None
            
        except User.DoesNotExist:
            return None 