import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Notification/Announcement/create_announcement.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> announcementList = [];
  TextEditingController searchController = TextEditingController();
  String selectedCategory = 'ทั้งหมด';
  SessionService _sessionService = SessionService();
  String? userRole; // เพิ่มตัวแปรเพื่อเก็บ role ของผู้ใช้

  @override
  void initState() {
    super.initState();
    getUserRoleAndAnnouncements();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getUserRoleAndAnnouncements() async {
    // ดึง role จาก session
    userRole = await _sessionService.getUserRole();
    // โหลดประกาศ
    await getAnnouncer();
    setState(() {});
  }

  Future<void> getAnnouncer() async {
    final response = await http.get(Uri.parse('$baseUrl/api/posts/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        announcementList = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  List<Map<String, dynamic>> get filteredAnnouncements {
    return announcementList.where((post) {
      final matchesTitle = post['title'].toString().toLowerCase().contains(
        searchController.text.toLowerCase(),
      );
      final matchesCategory =
          selectedCategory == 'ทั้งหมด' || post['category'] == selectedCategory;
      return matchesTitle && matchesCategory;
    }).toList();
  }

  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'announcement':
        return 'ประกาศ';
      case 'news':
        return 'ข่าวสาร';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ประกาศ"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'ค้นหาจากหัวข้อ...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  items:
                      ['ทั้งหมด', 'announcement', 'news']
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category == 'ทั้งหมด'
                                    ? 'ทุกประเภท'
                                    : getCategoryDisplayName(category),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                filteredAnnouncements.isEmpty
                    ? const Center(child: Text("ไม่พบประกาศที่ต้องการ"))
                    : ListView.builder(
                      itemCount: filteredAnnouncements.length,
                      itemBuilder: (context, index) {
                        final post = filteredAnnouncements[index];
                        final title = post['title'];
                        final content = post['content'];
                        final imageUrl = post['image_url'];
                        final publishedAt = post['published_at'];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AnnouncementDetailPage(post: post),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              bottom: 15,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (imageUrl != null && imageUrl != '')
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(imageUrl),
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    title ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "เผยแพร่เมื่อ: ${publishedAt.toString().substring(0, 10)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      // แสดงปุ่มโพสต์ประกาศใหม่หาก userRole ไม่ใช่ '1'
      floatingActionButton:
          userRole != '1'
              ? FloatingActionButton(
                onPressed: () {
                  // ไปหน้าโพสต์ประกาศใหม่
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAnnouncementPage(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
                tooltip: 'โพสต์ประกาศใหม่',
              )
              : null,
    );
  }
}

class AnnouncementDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const AnnouncementDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post['title'] ?? 'รายละเอียดข่าว')),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post['image_url'] != null && post['image_url'] != '')
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(post['image_url']),
              ),
            const SizedBox(height: 15),
            Text(
              post['title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "เผยแพร่เมื่อ: ${post['published_at'].toString().substring(0, 10)}",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Text(post['content'] ?? '', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
