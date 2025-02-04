import 'package:http/http.dart' as http;

class ScholarshipService {
  static const String baseUrl = 'http://localhost:8000/api';  // For local development
  // Use your production URL in production
  // static const String baseUrl = 'https://your-production-url.com/api';

  Future<void> fetchScholarships() async {
    final response = await http.get(Uri.parse('$baseUrl/scholarships/'));
    if (response.statusCode == 200) {
      print(response.body); // JSON data from the backend
    } else {
      throw Exception('Failed to load scholarships');
    }
  }
} 