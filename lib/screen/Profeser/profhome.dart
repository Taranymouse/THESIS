import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/Nav/bottom_nav.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Notification/Announcement/announcement_carousel.dart';
import 'package:project/screen/Menu/Prof/profmenubar.dart';
import 'package:project/screen/Notification/notification.dart';
import 'package:project/screen/Settings/setting.dart';

class ProfHomepage extends StatelessWidget {
  const ProfHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const NotificationPage(),
      const ProfHomepageContent(),
      const SettingScreen(),
    ];

    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        int currentIndex = (state is CurrentPage) ? state.currentIndex : 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'IT/CS THESIS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorPlate.colors[6].color,
              ),
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

class ProfHomepageContent extends StatefulWidget {
  const ProfHomepageContent({super.key});

  @override
  _ProfHomepageContentState createState() => _ProfHomepageContentState();
}

class _ProfHomepageContentState extends State<ProfHomepageContent> {
  final SessionService _sessionService = SessionService();
  String? displayName;
  String? email;
  int? id_user;
  List<Map<String, dynamic>> pinnedAnnouncements = [];

  @override
  void initState() {
    super.initState();
    _loadPinnedAnnouncements();
    initialize();
  }

  Future<void> initialize() async {
    await _loadDisplayName();
    await _onCheckUser();
    await onCheckProfessor();
  }

  Future<void> _loadPinnedAnnouncements() async {
    final response = await http.get(Uri.parse('$baseUrl/api/posts/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final newPinned =
          List<Map<String, dynamic>>.from(
            data,
          ).where((post) => post['is_pinned'] == true).toList();

      // เปรียบเทียบก่อน setState
      if (!_listEquals(pinnedAnnouncements, newPinned)) {
        setState(() {
          pinnedAnnouncements = newPinned;
        });
      }
    } else {
      print("❌ Failed to load announcements: ${response.body}");
    }
  }

  // ฟังก์ชันเปรียบเทียบ List<Map>
  bool _listEquals(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!mapEquals(a[i], b[i])) return false;
    }
    return true;
  }

  Future<void> _loadDisplayName() async {
    // ดึง displayName จาก SessionService
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
    return RefreshIndicator(
      onRefresh: () async {
        await _loadPinnedAnnouncements();
        await _onCheckUser();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                displayName != null
                    ? "ยินดีต้อนรับ: $displayName"
                    : "กำลังโหลดข้อมูลผู้ใช้...",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Text("ตำแหน่ง : อาจารย์"),
              const SizedBox(height: 20),
              const Text(
                "📢 ประกาศสำคัญ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              AnnouncementCarousel(pinnedAnnouncements: pinnedAnnouncements),
              const SizedBox(height: 20),
              const ProfMenu(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
