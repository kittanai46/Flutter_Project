import 'dart:convert';

import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Record extends StatefulWidget {
  final String studentId;

  const Record({Key? key, required this.studentId}) : super(key: key);

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  List<Map<String, dynamic>> leaveHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaveHistory();
  }

  Future<void> fetchLeaveHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '${APIConstants.baseURL}/api/leave-history/${widget.studentId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          leaveHistory = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load leave history');
      }
    } catch (e) {
      print('Error fetching leave history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'อนุมัติ':
        return '#4CAF50'; // สีเขียว
      case 'ไม่อนุมัติ':
        return '#F44336'; // สีแดง
      case 'รออนุมัติ':
        return '#FFC107'; // สีเหลือง
      default:
        return '#9E9E9E'; // สีเทา
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ภาพพื้นหลัง
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1,
              child: Image.asset(
                'assets/Images/Bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ปุ่มย้อนกลับ
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Image.asset(
                'assets/Images/icon_back.png',
                width: 40,
                height: 40,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // ไอคอนด้านขวา
          Positioned(
            top: 80,
            right: 20,
            child: Image.asset(
              'assets/Images/icon03.png',
              width: 50,
              height: 50,
            ),
          ),
          // ข้อความกลางหน้าจอ
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'ประวัติการลา',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // รายการประวัติการลา
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : leaveHistory.isEmpty
                    ? Center(child: Text('ไม่พบประวัติการลา'))
                    : ListView.builder(
                        itemCount: leaveHistory.length,
                        itemBuilder: (context, index) {
                          final leave = leaveHistory[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${leave['course_name']} (${leave['course_code']})',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text('ประเภท: ${leave['leave_type']}'),
                                  Text(
                                      'วันที่: ${leave['start_date']} - ${leave['end_date']}'),
                                  Text('เหตุผล: ${leave['reason']}'),
                                  Text(
                                      'สถานะ: ${leave['action'] ?? 'รออนุมัติ'}'),
                                  if (leave['comment'] != null &&
                                      leave['comment'].isNotEmpty)
                                    Text('ความคิดเห็น: ${leave['comment']}'),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(getStatusColor(
                                              leave['action'] ?? 'รออนุมัติ')
                                          .replaceAll('#', '0xFF'))),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      leave['action'] ?? 'รออนุมัติ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
