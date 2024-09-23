import 'dart:io';

import 'package:ClassTracking/Function/f1.dart';
import 'package:ClassTracking/Function/f2s.dart';
import 'package:ClassTracking/Function/f3.dart';
import 'package:ClassTracking/Student/Sbox/SBox4/ProfileS.dart';
import 'package:ClassTracking/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SBox4 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String idNumber;

  const SBox4({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
  }) : super(key: key);

  @override
  _SBox4State createState() => _SBox4State();
}

class _SBox4State extends State<SBox4> {
  String userName = 'ชื่อผู้ใช้';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      userName = '${widget.firstName} ${widget.lastName}';
    });
    await _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImage');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  void _navigateToPack1() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileS(idNumber: widget.idNumber),
      ),
    );
    if (result != null) {
      _loadUserData(); // Reload user data after returning from ProfileS
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ยืนยันการออกจากระบบ"),
          content: const Text("คุณแน่ใจหรือไม่ที่จะออกจากระบบ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: const Text('ตกลง'),
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
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1.1,
              child: Image.asset(
                'assets/Images/Bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 15,
            child: IconButton(
              icon: Image.asset(
                'assets/Images/icon_back.png',
                width: 40,
                height: 40,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Positioned(
            top: 90,
            left: 0,
            right: 10,
            child: Center(
              child: Text(
                'การตั้งค่า',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 5 - 20,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!) as ImageProvider
                        : const AssetImage('assets/Images/usericon.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 380,
            left: (MediaQuery.of(context).size.width - 360) / 2,
            child: GestureDetector(
              onTap: _navigateToPack1,
              child: const OptionBox(
                image: 'assets/Images/pack1.png',
                title: 'บัญชี',
                subtitle: 'บัญชีผู้ใช้ ข้อมูลส่วนตัวและโปรไฟล์',
              ),
            ),
          ),
          Positioned(
            top: 470,
            left: (MediaQuery.of(context).size.width - 360) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => f1()),
                );
              },
              child: const OptionBox(
                image: 'assets/Images/pack2.png',
                title: 'แจ้งเตือนและสิทธิ์',
                subtitle: 'การอนุญาตการขอสิทธิ์และแจ้งเตือน',
              ),
            ),
          ),
          Positioned(
            top: 560,
            left: (MediaQuery.of(context).size.width - 360) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => f2s()),
                );
              },
              child: const OptionBox(
                image: 'assets/Images/pack3.png',
                title: 'คู่มือการใช้งาน',
                subtitle: 'คู่มือและวิธีการใช้งานโดยเบื้องต้น',
              ),
            ),
          ),
          Positioned(
            top: 650,
            left: (MediaQuery.of(context).size.width - 360) / 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => f3()),
                );
              },
              child: const OptionBox(
                image: 'assets/Images/pack4.png',
                title: 'เกี่ยวกับแอพพลิเคชัน',
                subtitle: 'ข้อมูลต่างๆ ที่เกี่ยวกับแอพพลิเคชัน',
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/Images/exit.png',
                  width: 40,
                  height: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionBox extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const OptionBox({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 90,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 242, 176, 255),
        borderRadius: title == 'บัญชี'
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : title == 'เกี่ยวกับแอพพลิเคชัน'
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
                : BorderRadius.circular(0),
        border: title != 'บัญชี'
            ? const Border(
                top: BorderSide(
                  color: Color.fromARGB(255, 143, 135, 135),
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              image,
              width: 50,
              height: 50,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Image.asset(
              'assets/Images/arrow.png',
              width: 50,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}
