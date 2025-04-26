import 'package:flutter/material.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Loading/loading_screen.dart';
import 'package:project/screen/Student/AcademicPerformance/academic_performance.dart';
import 'package:project/screen/Student/RequestGroup/request_group.dart';

class AdminDocumentRouter extends StatelessWidget {
  AdminDocumentRouter({super.key});
  final SessionService sessionService = SessionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("จัดการเอกสาร"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: AdminHomepage()),
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
                  await Future.delayed(const Duration(seconds: 2));
                }, const PerformanceForm());
              },
            ),
            DocumentCard(
              title:
                  'แบบคำร้องขอเข้ารับการจัดสรรกลุ่มสำหรับการจัดทำโครงงานปริญญานิพนธ์',
              subtitle: '(CP00R)',
              onTap: () async {
                int? studentId = await sessionService.getIdStudent();

                if (studentId != null) {
                  await LoadingScreen.showWithNavigation(context, () async {
                    await Future.delayed(const Duration(seconds: 2));
                  }, RequestGroup(studentIds: [studentId]));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("ไม่พบข้อมูลรหัสนักศึกษา"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            DocumentCard(
              title: 'แบบคำร้องขอเสนอหัวข้อโครงงานปริญญานิพนธ์',
              subtitle: '(IT01S / CS01S)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("ยังไม่เปิดให้บริการ"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            DocumentCard(
              title: 'แบบคำร้องขอสอบข้อเสนอหัวข้อโครงงานปริญญานิพนธ์',
              subtitle: '(IT02S / CS02S)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("ยังไม่เปิดให้บริการ"),
                    duration: Duration(seconds: 1),
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
                  const SnackBar(
                    content: Text("ยังไม่เปิดให้บริการ"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            DocumentCard(
              title: 'แบบคำร้องขอสอบนำเสนอโครงงานปริญญานิพนธ์ที่เสร็จสมบูรณ์',
              subtitle: '(IT04S / CS04S)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("ยังไม่เปิดให้บริการ"),
                    duration: Duration(seconds: 1),
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
