import 'package:flutter/material.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Loading/loading_screen.dart';
import 'package:project/screen/Student/academic_performance.dart';
import 'package:project/screen/Student/request_group.dart';
import 'package:project/screen/home.dart';

class DocumentRouter extends StatelessWidget {
  const DocumentRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("จัดการเอกสาร"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: Homepage()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Project I", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DocumentCard(
              title: 'แบบขอตรวจคุณสมบัติในการมีสิทธิขอจัดทำโครงงานปริญญานิพนธ์',
              subtitle: '(IT00G / CS00G)',
              onTap: () async {
                await LoadingScreen.showWithNavigation(context, () async {
                  await Future.delayed(Duration(seconds: 2));
                }, const PerformanceForm());
              },
            ),
            DocumentCard(
              title:
                  'แบบคำร้องขอเข้ารับการจัดสรรกลุ่มสำหรับการจัดทำโครงงานปริญญานิพนธ์',
              subtitle: '(CP00R)',
              onTap: () async {
                await LoadingScreen.showWithNavigation(context, () async {
                  await Future.delayed(Duration(seconds: 2));
                }, RequestGroup(studentIds: [1, 3]));
              },
            ),
            DocumentCard(
              title: 'แบบคำร้องขอเสนอหัวข้อโครงงานปริญญานิพนธ์',
              subtitle: '(IT01S / CS01S)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("ยังไม่เปิดให้บริการ"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            DocumentCard(
              title: 'แบบคำร้องขอสอบข้อเสนอหัวข้อโครงงานปริญญานิพนธ์',
              subtitle: '(IT02S / CS02S)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("ยังไม่เปิดให้บริการ"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text("Project II", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DocumentCard(
              title: 'แบบคำร้องขอสอบติดตามความก้าวหน้าโครงงานปริญญานิพนธ์',
              subtitle: '(IT03S / CS03S)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("ยังไม่เปิดให้บริการ"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            DocumentCard(
              title: 'แบบคำร้องขอสอบนำเสนอโครงงานปริญญานิพนธ์ที่เสร็จสมบูรณ์',
              subtitle: '(IT04S / CS04S)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("ยังไม่เปิดให้บริการ"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DocumentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // แก้ตรงนี้!
            children: [
              const Icon(Icons.description, size: 30, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
