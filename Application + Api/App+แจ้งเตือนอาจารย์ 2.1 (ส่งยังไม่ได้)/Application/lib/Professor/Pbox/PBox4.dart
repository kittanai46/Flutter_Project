import 'package:ClassTracking/api_constants.dart';
import 'package:flutter/material.dart';

class PBox4 extends StatefulWidget {
  final String teacherId;
  final String firstName;
  final String lastName;

  const PBox4({
    Key? key,
    required this.teacherId,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  _PBox4State createState() => _PBox4State();
}

class _PBox4State extends State<PBox4> {
  List<Map<String, dynamic>> courses = [];
  String? selectedCourseCode;
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() => isLoading = true);
    try {
      final fetchedCourses =
          await APIConstants.getTeacherCourses(widget.teacherId);
      setState(() {
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching courses: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดรายวิชา')),
      );
    }
  }

  Future<void> sendMessage() async {
    if (selectedCourseCode == null ||
        titleController.text.isEmpty ||
        messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await APIConstants.sendCourseMessage(
        teacherId: widget.teacherId,
        courseCode: selectedCourseCode!,
        title: titleController.text,
        message: messageController.text,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งข้อความสำเร็จ')),
        );
        titleController.clear();
        messageController.clear();
        setState(() {
          selectedCourseCode = null;
        });
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อความ')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            top: 70,
            right: 40,
            child: Image.asset(
              'assets/Images/icon04.png',
              width: 50,
              height: 50,
            ),
          ),
          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'ส่งการประกาศข่าวสาร',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            bottom: 20,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สวัสดี อาจารย์ ${widget.firstName} ${widget.lastName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'เลือกรายวิชา',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: selectedCourseCode,
                    items: courses.map((course) {
                      return DropdownMenuItem<String>(
                        value: course['course_code'],
                        child: Text(
                            '${course['course_code']}[${course['section']}] - ${course['course_name']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCourseCode = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'หัวข้อ',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'เนื้อหาข่าวสาร',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : sendMessage,
                      child: Text('ส่งข้อความ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 223, 134, 240),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
