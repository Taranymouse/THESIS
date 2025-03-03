import 'package:flutter/material.dart';

class ColorPlate {
  final Color color;

  ColorPlate(this.color);

  static List<ColorPlate> colors = [
    ColorPlate(Color(0xFFA7C7E7)), // ฟ้าหม่น
    ColorPlate(Color(0xFFFFC40C)), // เหลืองจำปาดี
    ColorPlate(Color(0xFFE5E5E5)), // เทาอ่อน
    ColorPlate(Color(0xFF333333)), // ดำอ่อน
    ColorPlate(Color(0xFF555555)), // เทาเข้ม
    ColorPlate(Color(0xFFFAF3E0)), // ขาวครีม
    ColorPlate(Color(0xFF18756A)), // เขียว Veridian
  ];
}
