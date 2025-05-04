import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/Nav/bottom_nav.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Menu/STD/menubar.dart';
import 'package:project/screen/Notification/Announcement/announcement_carousel.dart';
import 'package:project/screen/Notification/notification.dart';
import 'package:project/screen/Settings/setting.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const NotificationPage(),
      const HomepageContent(),
      const SettingScreen(),
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

class HomepageContent extends StatefulWidget {
  const HomepageContent({super.key});

  @override
  _HomepageContentState createState() => _HomepageContentState();
}

class _HomepageContentState extends State<HomepageContent> {
  final SessionService _sessionService = SessionService();
  String? displayName;
  String? email;
  int? id_user;
  List<Map<String, dynamic>> pinnedAnnouncements = [];

  @override
  void initState() {
    super.initState();
    _loadPinnedAnnouncements();
    _loadDisplayName();
    _onCheckUser();
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
    String? cachedDisplayName = await _sessionService.getDisplayName();
    if (cachedDisplayName != null) {
      setState(() {
        displayName = cachedDisplayName;
      });
    } else {
      _onDisplayNameAPI();
    }
  }

  Future<void> _onDisplayNameAPI() async {
    String? token = await _sessionService.getAuthToken();
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
    if (token != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/user'),
        headers: {"Authorization": "$token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String fetchedEmail = data["email"];
        if (fetchedEmail == email) {
          await _sessionService.setIdUser(data['id_user']);
          setState(() {
            this.email = fetchedEmail;
            id_user = data['id_user'];
          });
          await _onCheckStudent();
        }
      }
    }
  }

  Future<void> _onCheckStudent() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/student/get/active_user/${id_user.toString()}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await _sessionService.setIdStudent(data['data']['id_student']);
      await _sessionService.saveStudentId(data['data']['code_student']);
      await _sessionService.saveUserName(data['data']['first_name']);
      await _sessionService.saveUserLastName(data['data']['last_name']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 20),
          const Text(
            "📢 ประกาศสำคัญ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AnnouncementCarousel(pinnedAnnouncements: pinnedAnnouncements),
          const SizedBox(height: 20),
          const Menu(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
