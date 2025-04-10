// backbttn.dart
import 'package:flutter/material.dart';

// สร้าง widget สำหรับปุ่มย้อนกลับ
class BackButtonWidget extends StatelessWidget {
  final Widget targetPage; // รับหน้าที่จะไปแทน

  const BackButtonWidget({Key? key, required this.targetPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back), // ไอคอนย้อนกลับ
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
          (Route<dynamic> route) => false, // ลบหน้าทุกหน้าที่อยู่ใน stack
        );
      },
    );
  }
}
