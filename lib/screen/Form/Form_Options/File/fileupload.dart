import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FileUploadWidget extends StatefulWidget {
  final List<PlatformFile>? initialFiles;
  final void Function(List<PlatformFile>)? onFilesPicked;

  const FileUploadWidget({Key? key, this.onFilesPicked, this.initialFiles})
      : super(key: key);

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  List<PlatformFile> pickedFiles = [];

  @override
  void initState() {
    super.initState();
    pickedFiles = widget.initialFiles ?? [];
  }

  @override
  void didUpdateWidget(covariant FileUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFiles != oldWidget.initialFiles) {
      setState(() {
        pickedFiles = widget.initialFiles ?? [];
      });
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          pickedFiles.addAll(result.files);
        });
        widget.onFilesPicked?.call(pickedFiles);
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void removeFile(int index) {
    setState(() {
      pickedFiles.removeAt(index);
    });
    widget.onFilesPicked?.call(pickedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('เลือกไฟล์'),
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.prompt(fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        if (pickedFiles.isNotEmpty)
          Column(
            children: pickedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: Text('• ${file.name}', overflow: TextOverflow.ellipsis)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeFile(index),
                      ),
                    ],
                  ),
                  if (file.extension != null &&
                      file.extension!.toLowerCase() != 'pdf' &&
                      file.path != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Image.file(
                        File(file.path!),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const Text(
                      'ไฟล์ PDF ไม่สามารถแสดงตัวอย่างได้',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  const Divider(),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }
}
