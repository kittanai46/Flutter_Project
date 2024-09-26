import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PBox3 extends StatefulWidget {
  final String teacherId;

  const PBox3({Key? key, required this.teacherId}) : super(key: key);

  @override
  _PBox3State createState() => _PBox3State();
}

class _PBox3State extends State<PBox3> {
  List<Map<String, dynamic>> _pendingLeaveRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingLeaveRequests();
  }

  Future<void> _fetchPendingLeaveRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests =
          await APIConstants.getPendingLeaveRequests(widget.teacherId);
      setState(() {
        _pendingLeaveRequests = requests;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveLeaveRequest(
      String leaveRequestId, bool isApproved) async {
    setState(() => _isLoading = true);
    try {
      final result = await APIConstants.approveLeaveRequest(
        leaveRequestId: leaveRequestId,
        teacherId: widget.teacherId,
        isApproved: isApproved,
      );
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(isApproved ? 'อนุมัติใบลาสำเร็จ' : 'ปฏิเสธใบลาสำเร็จ')),
        );
        _fetchPendingLeaveRequests(); // Refresh the list
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLeaveDetails(Map<String, dynamic> leaveRequest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายละเอียดใบลา'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('นิสิต: ${leaveRequest['student_name']}'),
                Text('รหัสนิสิต: ${leaveRequest['student_id']}'),
                Text('วิชา: ${leaveRequest['course_name']}'),
                Text('ประเภทการลา: ${leaveRequest['leave_type']}'),
                Text(
                    'วันที่เริ่มลา: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(leaveRequest['start_date']))}'),
                Text(
                    'วันที่สิ้นสุด: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(leaveRequest['end_date']))}'),
                Text('เหตุผล: ${leaveRequest['reason']}'),
                if (leaveRequest['leave_document_url'] != null)
                  TextButton(
                    child: Text('ดูเอกสารใบลา'),
                    onPressed: () {
                      // TODO: Implement document viewing logic
                    },
                  ),
                if (leaveRequest['medical_certificate_url'] != null)
                  TextButton(
                    child: Text('ดูใบรับรองแพทย์'),
                    onPressed: () {
                      // TODO: Implement document viewing logic
                    },
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ปิด'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
                  'การอนุมัติใบลา',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // รายการใบลาที่รอการอนุมัติ
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _pendingLeaveRequests.isEmpty
                    ? Center(child: Text('ไม่มีใบลาที่รอการอนุมัติ'))
                    : ListView.builder(
                        itemCount: _pendingLeaveRequests.length,
                        itemBuilder: (context, index) {
                          final leaveRequest = _pendingLeaveRequests[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                  '${leaveRequest['student_name']} - ${leaveRequest['course_name']}'),
                              subtitle: Text(
                                  'วันที่ลา: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(leaveRequest['start_date']))}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon:
                                        Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _approveLeaveRequest(
                                        leaveRequest['id'], true),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _approveLeaveRequest(
                                        leaveRequest['id'], false),
                                  ),
                                ],
                              ),
                              onTap: () => _showLeaveDetails(leaveRequest),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchPendingLeaveRequests,
        child: Icon(Icons.refresh),
        tooltip: 'รีเฟรชข้อมูล',
      ),
    );
  }
}
