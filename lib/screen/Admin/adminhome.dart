import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/Nav/bottom_nav.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Notification/Announcement/announcement_carousel.dart';
import 'package:project/screen/Menu/Admin/adminmenubar.dart';
import 'package:project/screen/Notification/notification.dart';
import 'package:project/screen/Settings/setting.dart';

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const NotificationPage(),
      const AdminHomepageContent(),
      const SettingScreen(),
    ];

    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        int currentIndex = (state is CurrentPage) ? state.currentIndex : 1;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'IT/CS THESIS',
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

class AdminHomepageContent extends StatefulWidget {
  const AdminHomepageContent({super.key});

  @override
  _AdminHomepageContentState createState() => _AdminHomepageContentState();
}

class _AdminHomepageContentState extends State<AdminHomepageContent> {
  final SessionService _sessionService = SessionService();
  String? displayName;
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
    // ดึง displayName จาก SessionService
    String? cachedDisplayName = await _sessionService.getDisplayName();
    if (cachedDisplayName != null) {
      setState(() {
        displayName = cachedDisplayName;
      });
    } else {
      // ถ้าไม่มีใน SessionService ให้โหลดจาก API
      _onCheckUser();
    }
  }

  Future<void> _onCheckUser() async {
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
        // บันทึก displayName ลงใน SessionService
        await _sessionService.saveDisplayName(fetchedDisplayName);
      } else {
        print("❌ Failed to fetch user data: ${response.body}");
      }
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
          Text(
            "ยินดีต้อนรับ: ${displayName}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Text("ตำแหน่ง : แอดมิน", style: TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          const Text(
            "📢 ประกาศสำคัญ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AnnouncementCarousel(pinnedAnnouncements: pinnedAnnouncements),
          SizedBox(height: 20),
          AdminMenu(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
