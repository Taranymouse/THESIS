import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  String selectedCategory = 'announcement';
  bool isPinned = false;

  // ฟังก์ชันสำหรับส่งข้อมูลไปยัง API
  Future<void> createAnnouncement() async {
    final String apiUrl = '$baseUrl/api/posts/'; // URL ของ API
    final Map<String, dynamic> newPost = {
      'title': titleController.text,
      'content': contentController.text,
      'category': selectedCategory,
      'is_pinned': isPinned,
      'image_url': imageUrlController.text,
      'published_at': null, // กำหนดให้เป็น null
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newPost),
    );

    if (response.statusCode == 201) {
      // ประกาศถูกสร้างสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ประกาศถูกสร้างเรียบร้อยแล้ว')),
      );
      Navigator.pop(context); // กลับไปยังหน้าหลักหลังจากโพสต์สำเร็จ
    } else {
      // หากมีข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการสร้างประกาศ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างประกาศใหม่'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Title TextField
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'หัวข้อประกาศ'),
            ),
            const SizedBox(height: 10),

            // Content TextField
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'เนื้อหาประกาศ'),
              maxLines: 5,
            ),
            const SizedBox(height: 10),

            // Image URL TextField
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'URL รูปภาพ'),
            ),
            const SizedBox(height: 10),

            // Category Dropdown
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newCategory) {
                setState(() {
                  selectedCategory = newCategory!;
                });
              },
              items:
                  ['announcement', 'news']
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category == 'announcement' ? 'ประกาศ' : 'ข่าวสาร',
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 10),

            // Is Pinned Checkbox
            Row(
              children: [
                Checkbox(
                  value: isPinned,
                  onChanged: (bool? value) {
                    setState(() {
                      isPinned = value!;
                    });
                  },
                ),
                const Text('ปักหมุด'),
              ],
            ),
            const SizedBox(height: 20),

            // Create Button
            ElevatedButton(
              onPressed: createAnnouncement,
              child: const Text('สร้างประกาศ'),
            ),
          ],
        ),
      ),
    );
  }
}
