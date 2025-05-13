# Tinder Based scholarship swipper

![linter.yaml](https://github.com/kyle-olivier20/week2_project/actions/workflows/linter.yaml/badge.svg) 
![tests.yaml](https://github.com/cloud-leon/Grantly/actions/workflows/tests.yml/badge.svg)


*Software scrapes and tags scholoarships based on key words may add a machine learning aspect to tag words in future*

Donald Knuth:
> If you optimize everything, you will always be unhappy
> Science is what we understand well enough to explain to a computer. Art is everything else.


## Usage
\*Find and auto apply to scholarships\*

## Historysymphonys



## Architecture
- RESTful API backend with Django
- Mobile-first Flutter frontend
- Firebase for authentication
- PostgreSQL for data persistence
- Redis for caching
- Celery for background tasks

## API Documentation
Base URLs:
- Development: `http://localhost:8000`
- Android: `http://10.0.2.2:8000`
- iOS: `http://127.0.0.1:8000`

Key endpoints:
- `/api/users/profile/` - User profile management
- `/api/scholarships/` - Scholarship listings
- `/api/applications/` - Application management

## Contributing
1. Fork the repository
2. Create feature branch
3. Make changes
4. Run tests
5. Submit pull request

## Troubleshooting
Common issues and solutions:
1. Database connection errors:
   - Check PostgreSQL is running
   - Verify database credentials

2. Firebase auth issues:
   - Verify Firebase configuration
   - Check API keys

3. Network errors:
   - Check Android/iOS network configuration
   - Verify API base URLs

## Contact Information

Name         | Email
------------ | -------------------------
Levi Makwei  | Levi.d.makwei@gmail.com

## License
[Your License Here]

## Acknowledgments
- Flutter team for the amazing framework
- Django community for the robust backend
- All contributors and testers
