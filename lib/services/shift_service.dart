import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shift_assignment.dart';
import '../../utils/constants.dart';

class ShiftService {
  static Future<List<ShiftAssignment>> fetchMySchedule() async {
    final url = Uri.parse('$baseUrl/shift-assignments/my-schedule');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('data: ${response.body}');
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ShiftAssignment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedule: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<String?> submitLeaveRequest({
    required int userId,
    required String token,
    required int shiftAssignmentId,
    required String reason,
  }) async {
    final url = Uri.parse('$baseUrl/leave-requests');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'shift_assignment_id': shiftAssignmentId,
        'reason': reason,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return null; // success
    } else {
      try {
        final data = jsonDecode(response.body);
        return data['message']?.toString() ??
            'เกิดข้อผิดพลาดในการส่งคำขอลาหยุด';
      } catch (_) {
        return 'เกิดข้อผิดพลาดในการส่งคำขอลาหยุด';
      }
    }
  }
}
