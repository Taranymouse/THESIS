import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/screen/Form/CheckPerForm/checkPerForm.dart';
import 'package:project/screen/Form/CheckPerForm/checkPerFormTest.dart';
import 'package:project/screen/Loading/loading_screen.dart';
import 'package:project/screen/Student/academic_performance.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

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
                    FontAwesomeIcons.fileLines,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  label: "จัดการเอกสาร",
                  color: Colors.blueAccent,
                  onPressed: () async {
                    await LoadingScreen.showWithNavigation(
                      context,
                      () async {
                        await Future.delayed(Duration(seconds: 2));
                      },
                      PerformanceForm()
                    );
                  },
                ),
                _buildButton(
                  context,
                  icon: FaIcon(
                    FontAwesomeIcons.listCheck,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  label: "รายการที่ต้องทำ",
                  color: Colors.redAccent,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("CheckList Coming soon...")),
                    );
                  },
                ),
                _buildButton(
                  context,
                  icon: FaIcon(
                    FontAwesomeIcons.userTie,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                  label: "ติดต่ออาจารย์",
                  color: Colors.redAccent,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Contact Coming soon...")),
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
