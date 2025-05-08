import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/screen/Coordinator/coor_prof_allocate.dart';
import 'package:project/screen/Coordinator/coordinator_allocate.dart';
import 'package:project/screen/Loading/loading_screen.dart';
import 'package:project/screen/Profeser/prof_allocate.dart';

class CoorMenu extends StatelessWidget {
  const CoorMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📋 เมนู",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: ColorPlate.colors[2].color,
              borderRadius: BorderRadius.circular(
                12,
              ), // ✅ เพิ่มความโค้งให้ดูนุ่มนวลขึ้น
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  icon: FaIcon(
                    FontAwesomeIcons.userGroup,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  label: "จัดสรรนักศึกษาภายในกลุ่ม",
                  color: Colors.blueAccent,
                  onPressed: () async {
                    await LoadingScreen.showWithNavigation(
                      context,
                      () async {
                        // จำลองการโหลดข้อมูล
                        await Future.delayed(const Duration(seconds: 2));
                      },
                      CoordinatorAllocate(), // หน้าใหม่ที่จะไป
                    );
                  },
                ),

                _buildButton(
                  context,
                  icon: FaIcon(
                    FontAwesomeIcons.peopleGroup,
                    color: Colors.deepPurple,
                    size: 30,
                  ),
                  label: "แบบคำร้องขอจัดสรรกลุ่ม",
                  color: Colors.blueAccent,
                  onPressed: () async {
                    await LoadingScreen.showWithNavigation(
                      context,
                      () async {
                        // จำลองการโหลดข้อมูล
                        await Future.delayed(const Duration(seconds: 2));
                      },
                      CoorProfAllocate(), // หน้าใหม่ที่จะไป
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required Widget icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            // decoration: BoxDecoration(
            //   color: color.withOpacity(0.1),
            //   shape: BoxShape.circle,
            // ),
            child: icon,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
