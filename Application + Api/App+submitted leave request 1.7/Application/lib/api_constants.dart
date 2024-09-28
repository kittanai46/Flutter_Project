import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class APIConstants {
  static const String baseURL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.44:4000',
  );

  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer <your-token>',
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

  // Authentication endpoints
  static String getLoginEndpoint() => '/login';
  static String getUsersEndpoint() => '/users';
  static String getUserByIdEndpoint(String userId) => '/api/user/$userId';

  // Attendance endpoints
  static String getLogAttendanceEndpoint() => '/log_attendance';

  // Leave system endpoints
  static String getLeaveTypesEndpoint() => '/api/leave-types';
  static String getLeaveRequestEndpoint() => '/api/leave-request';
  static String getLeaveHistoryEndpoint(String studentId) =>
      '/api/leave-history/$studentId';
  static String getPendingLeaveRequestsEndpoint(String teacherId) =>
      '/api/pending-leave-requests/$teacherId';
  static String getApproveLeaveRequestEndpoint(String leaveRequestId) =>
      '/api/approve-leave-request/$leaveRequestId';

  // Course endpoints
  static String getStudentCoursesEndpoint(String studentId) =>
      '/api/student_courses/$studentId';

  // Message endpoints
  static String getCourseMessagesEndpoint() => '/api/course_messages';
  static String getAllMessagesEndpoint() => '/api/messages';

  // User data methods
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final userResponse = await makeRequest(getUserByIdEndpoint(userId));
      final Map<String, dynamic> userData = jsonDecode(userResponse.body);

      final attendanceResponse = await makeRequest('/api/attendance/$userId');
      final List<dynamic> attendanceData = jsonDecode(attendanceResponse.body);

      Map<String, String> courseNames = {};
      for (var attendance in attendanceData) {
        courseNames[attendance['course_code']] = attendance['course_name'];
      }

      userData['attendance'] = attendanceData;
      userData['course_names'] = courseNames;

      print('User Data: $userData');
      return userData;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  // Attendance methods
  static Future<bool> sendAttendanceData(Map<String, dynamic> data) async {
    try {
      final response = await makeRequest(getLogAttendanceEndpoint(),
          method: 'POST', body: data);
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending attendance data: $e');
      return false;
    }
  }

  // Authentication methods
  static Future<Map<String, dynamic>> login(
      String idNumber, String password) async {
    try {
      final response = await makeRequest(
        getLoginEndpoint(),
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

  // Course methods
  static Future<List<Map<String, dynamic>>> getStudentCourses(
      String studentId) async {
    try {
      final response = await makeRequest(getStudentCoursesEndpoint(studentId));
      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = jsonDecode(response.body);
        return coursesJson
            .map((course) => {
                  'course_id': course['course_id']?.toString() ?? '',
                  'course_code': course['course_code'] ?? '',
                  'course_name': course['course_name'] ?? '',
                  'name':
                      "${course['course_code'] ?? ''} - ${course['course_name'] ?? ''}"
                })
            .toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getStudentCourses: $e');
      rethrow;
    }
  }

  // Leave system methods
  static Future<List<Map<String, dynamic>>> getLeaveTypes() async {
    try {
      final response = await makeRequest(getLeaveTypesEndpoint());
      if (response.statusCode == 200) {
        final List<dynamic> leaveTypesJson = jsonDecode(response.body);
        return leaveTypesJson
            .map((type) => type as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load leave types');
      }
    } catch (e) {
      print('Error in getLeaveTypes: $e');
      rethrow;
    }
  }

  static Future<String> uploadFile(String filePath, String fileType) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseURL/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.fields['fileType'] = fileType;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData['fileUrl']; // Assuming server returns the file URL
    } else {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> submitLeaveRequest(
      Map<String, dynamic> leaveData,
      List<http.MultipartFile> attachments) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseURL${getLeaveRequestEndpoint()}'));

      request.fields.addAll(
          leaveData.map((key, value) => MapEntry(key, value.toString())));

      for (var file in attachments) {
        request.files.add(file);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to submit leave request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in submitLeaveRequest: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> getLeaveHistory(
      String studentId) async {
    try {
      final response = await makeRequest(getLeaveHistoryEndpoint(studentId));
      if (response.statusCode == 200) {
        final List<dynamic> historyJson = jsonDecode(response.body);
        return historyJson.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load leave history');
      }
    } catch (e) {
      print('Error in getLeaveHistory: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingLeaveRequests(
      String teacherId) async {
    try {
      final response =
          await makeRequest(getPendingLeaveRequestsEndpoint(teacherId));
      if (response.statusCode == 200) {
        final List<dynamic> requestsJson = jsonDecode(response.body);
        return requestsJson
            .map((request) => request as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load pending leave requests');
      }
    } catch (e) {
      print('Error in getPendingLeaveRequests: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> approveLeaveRequest({
    required String leaveRequestId,
    required String teacherId,
    required String status,
    String? comment,
  }) async {
    try {
      final response = await makeRequest(
        getApproveLeaveRequestEndpoint(leaveRequestId),
        method: 'POST',
        body: {
          'status': status,
          'comment': comment,
          'approver_id': teacherId,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error in approveLeaveRequest: $e');
      rethrow;
    }
  }

  // Message methods
  static Future<List<Map<String, dynamic>>> getCourseMessages(
      List<String> courseCodes) async {
    try {
      final response = await makeRequest(
        getCourseMessagesEndpoint(),
        method: 'POST',
        body: {'courses': courseCodes},
      );
      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = jsonDecode(response.body);
        return messagesJson
            .map((message) => message as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load course messages');
      }
    } catch (e) {
      print('Error in getCourseMessages: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllMessages() async {
    try {
      final response = await makeRequest(getAllMessagesEndpoint());
      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = jsonDecode(response.body);
        return messagesJson
            .map((message) => message as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load all messages');
      }
    } catch (e) {
      print('Error in getAllMessages: $e');
      rethrow;
    }
  }
}
