import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingScreen {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // กดนอกกล่องไม่ได้
      builder: (_) => Center(
        child: FittedBox(
          fit: BoxFit.contain, // ทำให้ widget พอดีกับพื้นที่
          child: LoadingAnimationWidget.stretchedDots(
            color: Colors.white,
            size: 100, // ปรับขนาดได้ตามต้องการ
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop(); // ปิด dialog loading
  }

  static Future<void> showWithNavigation(
    BuildContext context,
    Future<void> Function() action, // ฟังก์ชันที่จะรอการทำงาน
    Widget page, // หน้าใหม่ที่ต้องการจะเปลี่ยนไป
  ) async {
    show(context); // แสดง loading

    try {
      await action(); // รอการทำงานของฟังก์ชัน
      hide(context); // ซ่อน loading
      await Future.delayed(Duration(milliseconds: 300));
      print("Navigating to ${page.runtimeType}"); // Debug log
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => page, // ไปที่หน้าใหม่
        ),
      );
    } catch (e, stackTrace) {
      hide(context); // ซ่อน loading เมื่อเกิดข้อผิดพลาด
      print("Error: $e\n$stackTrace"); // Log error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    }
  }
}
