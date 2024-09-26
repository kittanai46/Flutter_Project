import 'dart:convert';

import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    try {
      final response = await APIConstants.makeRequest(
        '/api/leave-history/${widget.studentId}',
      );
      final decodedResponse = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        leaveHistory = List<Map<String, dynamic>>.from(decodedResponse);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching leave history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildLeaveStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'อนุมัติ':
        color = Colors.green;
        break;
      case 'ไม่อนุมัติ':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color,
      labelStyle: TextStyle(color: Colors.white),
    );
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
                  'ประวัติการส่งใบลา',
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
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : leaveHistory.isEmpty
                    ? Center(child: Text('ไม่มีประวัติการลา'))
                    : ListView.builder(
                        itemCount: leaveHistory.length,
                        itemBuilder: (context, index) {
                          final leave = leaveHistory[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title:
                                  Text(leave['course_name'] ?? 'ไม่ระบุวิชา'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ประเภท: ${leave['type_name']}'),
                                  Text(
                                      'วันที่: ${formatDate(leave['start_date'])} - ${formatDate(leave['end_date'])}'),
                                ],
                              ),
                              trailing: _buildLeaveStatusChip(
                                  leave['status'] ?? 'รอการอนุมัติ'),
                              onTap: () {
                                // แสดงรายละเอียดเพิ่มเติมเมื่อกดที่รายการ
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('รายละเอียดการลา'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('วิชา: ${leave['course_name']}'),
                                          Text(
                                              'ประเภทการลา: ${leave['type_name']}'),
                                          Text(
                                              'วันที่เริ่ม: ${formatDate(leave['start_date'])}'),
                                          Text(
                                              'วันที่สิ้นสุด: ${formatDate(leave['end_date'])}'),
                                          Text(
                                              'สถานะ: ${leave['status'] ?? 'รอการอนุมัติ'}'),
                                          Text('เหตุผล: ${leave['reason']}'),
                                          if (leave['approval_comment'] != null)
                                            Text(
                                                'ความเห็นผู้อนุมัติ: ${leave['approval_comment']}'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('ปิด'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
