import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/Nav/bottom_nav.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Announcement/announcement_carousel.dart';
import 'package:project/screen/Menu/Coor/coormenubar.dart';
import 'package:project/screen/Settings/setting.dart';

class CoordinatorHome extends StatelessWidget {
  const CoordinatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Center(child: Text("🔔 แจ้งเตือน", style: TextStyle(fontSize: 24))),
      const CoordinatorHomeContent(),
      SettingScreen(),
    ];

    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        int currentIndex = (state is CurrentPage) ? state.currentIndex : 1;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'IT/CS Projects',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: IndexedStack(index: currentIndex, children: pages),
          bottomNavigationBar: BottomNav(),
        );
      },
    );
  }
}

// แยก Widget เพื่อให้ Code อ่านง่าย
class CoordinatorHomeContent extends StatefulWidget {
  const CoordinatorHomeContent({super.key});

  @override
  _CoordinatorHomeContentState createState() => _CoordinatorHomeContentState();
}

class _CoordinatorHomeContentState extends State<CoordinatorHomeContent> {
  final SessionService _sessionService = SessionService();
  String? displayName;
  String? email;
  int? id_user;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await _loadDisplayName();
    await _onCheckUser();
    await onCheckProfessor();
  }

  Future<void> _loadDisplayName() async {
    String? cachedDisplayName = await _sessionService.getDisplayName();
    if (cachedDisplayName != null) {
      setState(() {
        displayName = cachedDisplayName;
      });
    } else {
      // ถ้าไม่มีใน SessionService ให้โหลดจาก API
      _onDisplayNameAPI();
    }
  }

  Future<void> _onDisplayNameAPI() async {
    String? token = await _sessionService.getAuthToken();
    print("Token : $token");
    if (token != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/user'),
        headers: {"Authorization": "$token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String fetchedDisplayName = data["display_name"];
        setState(() {
          displayName = fetchedDisplayName;
        });
        await _sessionService.saveDisplayName(fetchedDisplayName);
      } else {
        print("❌ Failed to fetch user data: ${response.body}");
      }
    }
  }

  Future<void> _onCheckUser() async {
    String? token = await _sessionService.getAuthToken();
    String? email = await _sessionService.getUserSession();
    print("Token : $token");
    if (token != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/user'),
        headers: {"Authorization": "$token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String fetchedEmail = data["email"];
        if (fetchedEmail == email) {
          print("!!##  Email is $fetchedEmail");
          print("!!## id_user : ${data['id_user']}");
          await _sessionService.setIdUser(data['id_user']);
          final test_id_user = await _sessionService.getIdUser();
          print("TEST id_user : $test_id_user");
          setState(() {
            email = fetchedEmail;
            id_user = data['id_user'];
          });
        } else {
          print("Email is not in use.");
        }
      } else {
        print("❌ Failed to fetch user data: ${response.body}");
      }
    }
  }

  Future<void> onCheckProfessor() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/groups/professors'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final getIdUser = await _sessionService.getIdUser();
        print("!!## GET id_user : $getIdUser");

        // สร้าง List ของอาจารย์ขึ้นมา
        final List<Map<String, dynamic>> professorList =
            List<Map<String, dynamic>>.from(data);

        // หาว่ามีอาจารย์คนไหน id_user ตรงกับ session ไหม
        final matchedProfessor = professorList.firstWhere(
          (prof) => prof['id_user'] == getIdUser,
          orElse: () => {},
        );

        // ถ้ามีเจอ (คือ matchedProfessor ไม่ใช่อันว่าง)
        if (matchedProfessor.isNotEmpty) {
          final int idMember = matchedProfessor['id_member'];
          final int idGroup = matchedProfessor['id_group'];
          await _sessionService.setIdmember(idMember);
          await _sessionService.setProjectGroupId(idGroup);
          print('พบอาจารย์แล้ว => id_member: $idMember , id_group $idGroup');
          final test_id_member = await _sessionService.getIdmember();
          final test_id_group_project =
              await _sessionService.getProjectGroupId();
          print(
            "TEST => id_member : $test_id_member , id_group_project : $test_id_group_project",
          );
        } else {
          print('ไม่พบอาจารย์ที่ id_user ตรงกับ session');
        }
      } else {
        print('Failed to fetch professors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in onCheckProfessor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          // แสดง Email ที่ล็อกอิน
          Text(
            displayName != null
                ? "ยินดีต้อนรับ: $displayName"
                : "กำลังโหลดข้อมูลผู้ใช้...",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Text("ตำแหน่ง : ผู้ประสานงาน", style: TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          AnnouncementCarousel(),
          const SizedBox(height: 20),
          CoorMenu(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
