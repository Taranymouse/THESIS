import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/screen/Form/Form_Options/File/fileupload.dart';

class CreateAnnouncementPage extends StatefulWidget {
  final Map<String, dynamic>? editPost; // ถ้ามีคือโหมดแก้ไข

  const CreateAnnouncementPage({super.key, this.editPost});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String selectedCategory = 'announcement';
  bool isPinned = false;
  PlatformFile? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.editPost != null) {
      // โหมดแก้ไข
      final post = widget.editPost!;
      titleController.text = post['title'] ?? '';
      contentController.text = post['content'] ?? '';
      selectedCategory = post['category'] ?? 'announcement';
      isPinned = post['is_pinned'] ?? false;
      // ไม่ต้องเติม imageUrlController เพราะจะใช้ FileUploadWidget
    }
  }

  Future<void> submitAnnouncement() async {
    String? imageUrl;

    // ถ้ามีการเลือกไฟล์ใหม่ ให้ใช้ชื่อไฟล์หรือ path
    if (selectedImage != null) {
      imageUrl = selectedImage!.name; // หรือ selectedImage!.path ตามที่ต้องการ
    } else if (widget.editPost != null) {
      // ถ้าแก้ไขแต่ไม่เลือกรูปใหม่ ใช้รูปเดิม
      imageUrl = widget.editPost!['image_url'] ?? '';
    }

    final Map<String, dynamic> postMap = {
      'title': titleController.text,
      'content': contentController.text,
      'category': selectedCategory,
      'is_pinned': isPinned,
      'image_url': imageUrl ?? '', // ใช้ชื่อไฟล์หรือ path ที่เลือก
      'published_at': null,
    };

    final isEdit = widget.editPost != null;
    final apiUrl =
        isEdit
            ? '$baseUrl/api/posts/${widget.editPost!['id']}'
            : '$baseUrl/api/posts/';

    final response =
        isEdit
            ? await http.put(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(postMap),
            )
            : await http.post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(postMap),
            );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'แก้ไขประกาศสำเร็จ' : 'สร้างประกาศสำเร็จ'),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาด')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editPost != null ? 'แก้ไขประกาศ' : 'สร้างประกาศใหม่',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'หัวข้อประกาศ'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'เนื้อหาประกาศ'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            const Text("อัพโหลดรูปภาพ"),
            FileUploadWidget(
              initialFiles: selectedImage != null ? [selectedImage!] : [],
              onFilesPicked: (files) {
                setState(() {
                  selectedImage = files.isNotEmpty ? files.first : null;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("ประเภท :"),
                const SizedBox(width: 10),
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
                                category == 'announcement'
                                    ? 'ประกาศ'
                                    : 'ข่าวสาร',
                                style: GoogleFonts.prompt(),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),

            const SizedBox(height: 10),
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
            ElevatedButton(
              onPressed: submitAnnouncement,
              child: Text(
                widget.editPost != null ? 'บันทึกการแก้ไข' : 'สร้างประกาศ',
                style: GoogleFonts.prompt(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
