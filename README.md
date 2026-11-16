# Project : Bluetooth Class Tracking

<p align="center">
  <b>Tracking Student Attendance via Bluetooth Beacon</b><br>
  คลังพัฒนาระบบเช็กชื่อนิสิตด้วย Bluetooth Beacon พร้อมแอปมือถือ เว็บสำหรับอาจารย์ API และฐานข้อมูล
</p>

---

## About Project

Flutter_Project เป็น repository สำหรับเก็บงานพัฒนาและต้นแบบของปริญญานิพนธ์ **ระบบเช็คชื่อนิสิตเข้าห้องเรียนด้วยบลูทูธบีคอน** โดยมีเป้าหมายให้นิสิตใช้แอปมือถือรับสัญญาณ Beacon และส่งข้อมูลประกอบการบันทึกการเข้าเรียนผ่าน API

ภายในมีทั้งแอป Flutter หลายช่วงการพัฒนา ตัวอย่างทดลองสแกน Bluetooth โค้ดสำหรับ ESP32 รวมถึง SQL และฝั่ง Node.js ที่รองรับเว็บและ API โครงสร้างจึงสะท้อนลำดับการทดลองและเพิ่มฟังก์ชันของระบบ มากกว่าการมีแอปเวอร์ชันเดียวอยู่ที่ราก repository

ระบบแยกบทบาทนิสิตกับอาจารย์ และมีส่วนจัดการรายวิชา ประวัติการเข้าเรียน ประกาศ และคำร้องลาในเวอร์ชันที่เชื่อม API

---

## System Overview

| ส่วนประกอบ | หน้าที่ |
|---|---|
| ESP32 / Beacon | กระจายข้อมูล BLE Advertisement สำหรับให้แอปนำไปตรวจจับ |
| Flutter Application | สแกนสัญญาณ แสดงข้อมูลผู้ใช้ และเรียก API ตามบทบาท |
| Node.js API | รับและส่งข้อมูลการเข้าเรียน ประกาศ และคำร้องลา |
| Web Application | มีหน้าเว็บสำหรับอาจารย์ผ่าน Express และ EJS |
| MySQL Database | จัดเก็บผู้ใช้ รายวิชา การลงทะเบียน การเข้าเรียน และข้อมูลที่เกี่ยวข้อง |

ลำดับการเช็กชื่อโดยภาพรวม: ESP32 ส่งสัญญาณ → แอปสแกน BLE → ส่งข้อมูลผ่าน HTTP API → บันทึกใน MySQL → แสดงข้อมูลในแอปหรือเว็บ

การสแกน BLE เป็นการอ่านสัญญาณที่กระจายออกมา ไม่ได้จำเป็นต้องจับคู่เชื่อมต่อกับ Beacon เหมือนอุปกรณ์ Bluetooth ทั่วไป

---

## Features

### Student Application

- เข้าสู่ระบบและเรียกข้อมูลผู้ใช้จาก API
- ดูรายวิชาที่เกี่ยวข้องและประวัติการเข้าเรียน
- มีส่วนสแกน Bluetooth / UUID เพื่อใช้ประกอบกระบวนการเช็กชื่อ
- ดูข้อความหรือประกาศของรายวิชา
- ส่งคำร้องลาและแนบไฟล์ประกอบ
- ดูประวัติคำร้องลาและสถานะที่ระบบส่งกลับ

### Teacher Application & Website

- ดูข้อมูลรายวิชาและรายชื่อนิสิตตามวิชา / Section
- ดูและแก้ไขข้อมูลการเข้าเรียนในส่วนเว็บ
- กำหนดเกณฑ์เวลาเข้าเรียนและมาสายใน Route ที่เตรียมไว้
- ส่งข้อความหรือประกาศไปยังนิสิตของรายวิชา
- อ่านคำร้องลาที่รอพิจารณา
- เปิดเอกสารแนบและอนุมัติหรือปฏิเสธคำร้องพร้อมความเห็น

### Bluetooth Experiments

- ตัวอย่างสแกนตาม MAC Address ทั้งแบบ Manual และ Auto
- ตัวอย่างสแกนและอ่าน UUID จาก Manufacturer Data
- ทดลองใช้งาน `flutter_blue_plus`
- โค้ด ESP32 สำหรับกระจาย iBeacon และตัวอย่างสลับข้อมูล Beacon

ฟังก์ชันและความพร้อมต่างกันระหว่างโฟลเดอร์เวอร์ชัน ควรเลือกแอป API และฐานข้อมูลจากชุดที่สอดคล้องกัน

---

## Database Contents

ไฟล์ SQL แสดงโครงสร้างข้อมูลหลัก เช่น:

- `users` และ `students`: ผู้ใช้ บทบาท และข้อมูลนิสิต
- `courses`, `course_teachers` และ `enrollments`: วิชา ผู้สอน และการลงทะเบียน
- `attendance` และ `attendance_rules`: สถานะการเข้าเรียนและเกณฑ์เวลา
- `log_attendance`: บันทึกข้อมูลการตรวจเข้าเรียน
- `messages`: ประกาศหรือข้อความของรายวิชา

สถานะการเข้าเรียนใน Schema ตัวอย่างประกอบด้วย `present`, `absent`, `late` และ `leave` ส่วนตารางเพิ่มเติมขึ้นกับ SQL ของเวอร์ชันที่เลือก

---

## Project Structure

```text
Flutter_Project/
├── Application/          # แอปต้นแบบ 1.0–1.3 และการทดลอง UI / Scan
├── Application + Api/    # ชุดแอปและ API ตามช่วงการพัฒนา 1.0–2.1
├── BluetoothScanner/    # ตัวอย่างสแกน BLE แยกหัวข้อ
├── Database/            # SQL หลายช่วงเวลาและ Schema แยกตาราง
└── iBeaconBLE/          # ตัวอย่างโค้ด ESP32 ที่เก็บเป็นไฟล์ .txt
```

ชุดหนึ่งที่มีส่วนแอปและ API อยู่ด้วยกันคือ:

```text
Application + Api/
  App+แจ้งเตือนอาจารย์ 2.1/
    Application/         # Flutter Project
    Api/                 # Node.js, Express, Routes และ EJS Views
    5-10-67.sql           # SQL ของชุดนี้
```

---

## Technology Stack

### Mobile

- Flutter และ Dart
- `flutter_blue_plus`
- `permission_handler`
- `http` และ `socket_io_client`
- `shared_preferences`
- `file_picker`, `image_picker`, `path_provider` และ `open_file`

### API & Web

- Node.js และ Express
- EJS Templates
- MySQL ผ่าน `mysql2`
- `bcrypt`, `express-validator` และ Session Middleware
- Multer สำหรับข้อมูลไฟล์ที่อัปโหลด
- มีโค้ดทดลอง Socket.IO ในฝั่งเซิร์ฟเวอร์บางไฟล์

### Hardware

- ESP32
- Arduino C/C++ และ BLE Libraries
- BLE Advertisement / iBeacon

---

## Getting Started

### 1. Select a Version

```bash
git clone https://github.com/kittanai46/Flutter_Project.git
cd Flutter_Project
```

เลือกโฟลเดอร์แอปและ API ที่ต้องการศึกษา อย่ารัน `flutter pub get` จากราก repository เพราะ Flutter Project อยู่ในโฟลเดอร์ย่อย

### 2. Prepare Database & API

เตรียม MySQL และนำเข้า SQL ที่เข้ากันกับเวอร์ชันที่เลือก จากนั้นเข้าโฟลเดอร์ `Api`, ติดตั้ง Dependency ด้วย `npm install` และปรับการเชื่อมต่อใน `dbConnection.js` ให้ตรงกับฐานข้อมูลของตนเอง

ในชุด `App+แจ้งเตือนอาจารย์ 2.1` มีจุดที่ต้องตรวจต่อก่อนเริ่มเซิร์ฟเวอร์:

- Script ใน `package.json` อ้างถึง `server.js` แต่ไฟล์ที่เก็บใช้ชื่อ `Server.js`
- `Server.js` Export ตัว Express App แต่ยังไม่มีคำสั่ง `listen()` ในไฟล์นั้น
- `routers_app.js` มีการเปิดเซิร์ฟเวอร์และ Socket.IO แต่ยังอ้างถึง Route Module และ Dependency ที่ไม่ได้อยู่ครบในชุดเดียวกัน

จึงต้องเลือก Entry Point และจัด Dependency / Route ให้สอดคล้องก่อนทดลองเชื่อมกับมือถือ

### 3. Run Flutter Application

เข้า Flutter Project ที่เลือก เช่น:

```bash
cd "Application + Api/App+แจ้งเตือนอาจารย์ 2.1/Application"
flutter pub get
flutter run --dart-define=API_BASE_URL=http://YOUR_API_HOST:4000
```

`API_BASE_URL` ใช้กับชุดที่มี `lib/api_constants.dart` ซึ่งอ่านค่าผ่าน `String.fromEnvironment` ส่วนเวอร์ชันเก่าอาจกำหนด URL ไว้คนละตำแหน่ง อุปกรณ์ต้องเข้าถึง API Host ได้ และการสแกนต้องเปิด Bluetooth พร้อมสิทธิ์ที่เวอร์ชัน Android/iOS กำหนด

### 4. Test Beacon

เลือกตัวอย่างใน `iBeaconBLE` แล้วนำไปเตรียมเป็น Arduino Sketch สำหรับบอร์ดที่ใช้ ตรวจ UUID, Major, Minor และรูปแบบ Advertisement ให้ตรงกับวิธีตรวจจับในแอป โค้ด Beacon แต่ละไฟล์เป็นคนละแนวทางการทดลอง

---

## Project Status

เป็นคลังต้นแบบและประวัติการพัฒนาของโครงงาน มีหลายเวอร์ชันและบางส่วนยังต้องจัด Environment หรือเชื่อมโค้ดเพิ่มก่อนรันครบระบบ README นี้อธิบายความสามารถที่พบในไฟล์ตัวอย่างและชุด API ที่ตรวจ ไม่ได้ยืนยันว่าทุกเวอร์ชันทำงานครบหรือผ่านการทดสอบบนฮาร์ดแวร์จริงแล้ว

---

## Repository Owner

[Kittanai Srikham](https://github.com/kittanai46)

