import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Loading/loading_screen.dart';
import 'package:project/screen/Student/AcademicPerformance/academic_performance.dart';
import 'package:project/screen/Student/RequestGroup/request_group.dart';
import 'package:project/screen/home.dart';

class DocumentRouter extends StatefulWidget {
  const DocumentRouter({super.key});

  @override
  _DocumentRouterState createState() => _DocumentRouterState();
}

class _DocumentRouterState extends State<DocumentRouter> {
  final SessionService sessionService = SessionService();
  late int? id_user;

  @override
  void initState() {
    super.initState();
    initializeSession();
  }

  Future<void> initializeSession() async {
    await _onCheckStudent();
    _checkGroupProject();
  }

  Future<void> _checkGroupProject() async {
    print("--- FROM _checkGroupProject ---");
    int? id_group_project = await sessionService.getProjectGroupId();

    if (id_group_project != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/student/get/$id_group_project'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // ✅ ดึงรายการ id_student ทั้งหมดจาก response
        final List<int> studentIds =
            (data['data'] as List)
                .map((student) => student['id_student'] as int)
                .toList();

        print("📌 studentIds: $studentIds");

        // ✅ บันทึกเก็บไว้ใน SessionService
        await sessionService.saveUpdatedStudentIds(studentIds);
      } else {
        print("❌ Failed to fetch group project data: ${response.body}");
      }
    } else {
      print("ยังไม่มีการจัดกลุ่มโปรเจค");
    }
  }

  Future<void> _onCheckStudent() async {
    print("--- FROM _onCheckStudent ---");
    id_user = await sessionService.getIdUser();
    final response = await http.get(
      Uri.parse('$baseUrl/api/student/get/active_user/${id_user.toString()}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['data']['id_group_project'] != null) {
        await sessionService.setProjectGroupId(
          data['data']['id_group_project'],
        );
      } else {
        print("นักศึกษายังไม่ได้ทำ IT00G / CS00G");
      }
    } else {
      print("❌ Failed to fetch user data: ${response.body}");
    }
    String? testname = await sessionService.getUserName();
    String? testlast = await sessionService.getUserLastName();
    String? teststudentid = await sessionService.getStudentId();
    int? test_idgroupproject = await sessionService.getProjectGroupId();
    print("ข้อมูลนักศึกษา : $teststudentid $testname $testlast");
    print("id กลุ่มโปรเจค : $test_idgroupproject");
    print(
      "บันทึกข้อมูลจาก API /api/student/get/active_user/${id_user.toString()}",
    );
  }

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
                  await Future.delayed(const Duration(seconds: 2));
                }, PerformanceForm());
              },
            ),
            DocumentCard(
              title:
                  'แบบคำร้องขอเข้ารับการจัดสรรกลุ่มสำหรับการจัดทำโครงงานปริญญานิพนธ์',
              subtitle: '(CP00R)',
              onTap: () async {
                final updatedIds = await sessionService.getUpdatedStudentIds();

                if (updatedIds != null) {
                  await LoadingScreen.showWithNavigation(context, () async {
                    await Future.delayed(const Duration(seconds: 2));
                  }, RequestGroup(studentIds: updatedIds));
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
