import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/Nav/bottom_nav.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Announcement/announcement_carousel.dart';
import 'package:project/screen/Menu/STD/menubar.dart';
import 'package:project/screen/Settings/setting.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Center(child: Text("🔔 แจ้งเตือน", style: TextStyle(fontSize: 24))),
      const HomepageContent(),
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
class HomepageContent extends StatefulWidget {
  const HomepageContent({super.key});

  @override
  _HomepageContentState createState() => _HomepageContentState();
}

class _HomepageContentState extends State<HomepageContent> {
  final SessionService _sessionService = SessionService();
  String? displayName;

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
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
    String? role = await _sessionService.getUserRoleSession();
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
          // แสดง Email ที่ล็อกอิน
          Text(
            displayName != null
                ? "ยินดีต้อนรับ: $displayName"
                : "กำลังโหลดข้อมูลผู้ใช้...",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          AnnouncementCarousel(),
          SizedBox(height: 20),
          Menu(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
