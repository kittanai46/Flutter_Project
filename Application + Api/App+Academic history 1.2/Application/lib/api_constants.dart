import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class APIConstants {
  static const String baseURL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.50.10.193:4000', // แทนที่ด้วย URL จริงของคุณ
  );

  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer <your-token>', // ถ้ามีการใช้ token
  };

  static Future<bool> isServerOnline() async {
    try {
      final response = await http
          .get(Uri.parse(baseURL), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (error) {
      print('Error checking server status: $error');
      return false;
    }
  }

  static Future<http.Response> makeRequest(String endpoint,
      {String method = 'GET', Map<String, dynamic>? body}) async {
    try {
      http.Response response;
      final Uri uri = Uri.parse('$baseURL$endpoint');

      print('Making $method request to: $uri');
      if (body != null) {
        print('Request body: $body');
      }

      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: _headers)
              .timeout(const Duration(seconds: 10));
          break;
        case 'POST':
          response = await http
              .post(uri, headers: _headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 10));
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      print('API Response (${response.statusCode}): ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Request failed: $error');
      rethrow;
    }
  }

  static String getLoginEndpoint() {
    return '/login';
  }

  static String getUsersEndpoint() {
    return '/users';
  }

  static String getUserByIdEndpoint(String userId) {
    return '/api/user/$userId';
  }

  static String getLogAttendanceEndpoint() {
    return '/log_attendance';
  }

  static Future<Map<String, dynamic>> getUserData(String userId) async {
    final endpoint = getUserByIdEndpoint(userId);
    try {
      final response = await makeRequest(endpoint);
      print('User data response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }

  static Future<bool> sendAttendanceData(Map<String, dynamic> data) async {
    final endpoint = getLogAttendanceEndpoint();
    try {
      final response = await makeRequest(endpoint, method: 'POST', body: data);
      print(
          'Attendance data sent. Response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending attendance data: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> login(
      String idNumber, String password) async {
    final endpoint = getLoginEndpoint();
    try {
      final response = await makeRequest(
        endpoint,
        method: 'POST',
        body: {
          'id_number': idNumber,
          'password': password,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error during login: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // New function to get course names
  static Future<Map<String, String>> getCoursesNames(
      List<String> courseCodes) async {
    try {
      final response = await makeRequest(
        '/get-course-names',
        method: 'POST',
        body: {'course_codes': courseCodes},
      );

      if (response.statusCode == 200) {
        return Map<String, String>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load course names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting course names: $e');
      return {};
    }
  }
}
