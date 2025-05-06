import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

        // เรียงโพสต์จาก updated_at หรือ published_at ล่าสุด ไปเก่า
        announcementList.sort((a, b) {
          final aDate =
              DateTime.tryParse(a['updated_at'] ?? a['published_at'] ?? '') ??
              DateTime(2000);
          final bDate =
              DateTime.tryParse(b['updated_at'] ?? b['published_at'] ?? '') ??
              DateTime(2000);
          return bDate.compareTo(aDate); // เรียงจากใหม่ -> เก่า
        });
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
                Row(
                  children: [
                    const Text("ประเภท :"),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedCategory,
                      style: GoogleFonts.prompt(color: Colors.black),
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
                                    style: GoogleFonts.prompt(),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: getAnnouncer,
              child:
                  filteredAnnouncements.isEmpty
                      ? Center(
                        child: Text(
                          "ไม่พบประกาศที่ต้องการ",
                          style: GoogleFonts.prompt(),
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredAnnouncements.length,
                        itemBuilder: (context, index) {
                          final post = filteredAnnouncements[index];
                          print("POST : => $post");
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
                                    // ปุ่ม 3 จุด มุมขวาบน
                                    if (userRole != '1')
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_horiz),
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          CreateAnnouncementPage(
                                                            editPost: post,
                                                          ),
                                                ),
                                              );
                                              if (result == true)
                                                await getAnnouncer();
                                            } else if (value == 'delete') {
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (ctx) => AlertDialog(
                                                      title: Text(
                                                        'ลบโพสต์',
                                                        style:
                                                            GoogleFonts.prompt(),
                                                      ),
                                                      content: Text(
                                                        'คุณแน่ใจว่าต้องการลบโพสต์นี้?',
                                                        style:
                                                            GoogleFonts.prompt(),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'ยกเลิก',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            'ลบ',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm == true) {
                                                final res = await http.delete(
                                                  Uri.parse(
                                                    '$baseUrl/api/posts/${post['id']}',
                                                  ),
                                                );
                                                if (res.statusCode == 200) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'ลบโพสต์สำเร็จ',
                                                      ),
                                                    ),
                                                  );
                                                  await getAnnouncer();
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'เกิดข้อผิดพลาดในการลบ',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          itemBuilder:
                                              (context) => [
                                                PopupMenuItem(
                                                  value: 'edit',
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.edit,
                                                      color: Colors.orange,
                                                    ),
                                                    title: Text(
                                                      'แก้ไขโพสต์',
                                                      style:
                                                          GoogleFonts.prompt(),
                                                    ),
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    title: Text(
                                                      'ลบโพสต์',
                                                      style:
                                                          GoogleFonts.prompt(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                        ),
                                      ),
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
          ),
        ],
      ),
      // แสดงปุ่มโพสต์ประกาศใหม่หาก userRole ไม่ใช่ '1'
      floatingActionButton:
          userRole != '1'
              ? FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateAnnouncementPage(),
                    ),
                  );
                  // ถ้าสร้าง/แก้ไขสำเร็จ (result == true)
                  if (result == true) {
                    await getAnnouncer(); // เรียกฟังก์ชันดึงข้อมูลใหม่
                  }
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
