import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FileUploadWidget extends StatefulWidget {
  final PlatformFile? initialFile; // ✅ เพิ่มตัวรับไฟล์เดิม
  final void Function(PlatformFile? file)? onFilePicked;

  const FileUploadWidget({Key? key, this.onFilePicked, this.initialFile})
    : super(key: key);

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  PlatformFile? pickedFile;

  @override
  void initState() {
    super.initState();
    pickedFile = widget.initialFile; // ✅ กำหนดไฟล์เริ่มต้น
  }

  @override
  void didUpdateWidget(covariant FileUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFile != oldWidget.initialFile &&
        widget.initialFile != pickedFile) {
      setState(() {
        pickedFile = widget.initialFile;
      });
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          pickedFile = result.files.first;
        });
        widget.onFilePicked?.call(pickedFile);
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void removeFile() {
    setState(() {
      pickedFile = null;
    });
    widget.onFilePicked?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: pickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('เลือกไฟล์'),
            style: ElevatedButton.styleFrom(
              textStyle: GoogleFonts.prompt(
                fontSize: 12,
              ), // กำหนด style ข้อความ
            ),
          ),
          const SizedBox(height: 10),
          if (pickedFile != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ชื่อไฟล์: ${pickedFile!.name}'),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: removeFile,
                  tooltip: 'ลบไฟล์ที่เลือก',
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (pickedFile!.extension != null &&
                pickedFile!.extension!.toLowerCase() != 'pdf' &&
                pickedFile!.path != null)
              Image.file(
                File(pickedFile!.path!),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              const Text(
                'ไฟล์ PDF ไม่สามารถแสดงตัวอย่างได้',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ],
      ),
    );
  }
}
