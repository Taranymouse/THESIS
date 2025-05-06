import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDetailpage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailpage({super.key, required this.student});

  void showImageDialog(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Transcript',
      pageBuilder: (_, __, ___) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.95),
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                              child: Text(
                                'โหลดรูปไม่ได้',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final head = student['head_info'];
    final subjects = List<Map<String, dynamic>>.from(student['subject_grades']);
    final transcriptUrl = student['transcript_file'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          'รายละเอียด IT00G/CS00G',
          style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ข้อมูลส่วนหัว
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${head['first_name']} ${head['last_name']}',
                                style: GoogleFonts.prompt(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'รหัส: ${head['code_student']}',
                                style: GoogleFonts.prompt(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.blueGrey[300],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'ปี ${head['year']} เทอม ${head['term_name']}',
                                    style: GoogleFonts.prompt(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ผลการเรียนรายวิชา
                Text(
                  'ผลการเรียนรายวิชา',
                  style: GoogleFonts.prompt(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    child:
                        subjects.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'ไม่มีข้อมูลรายวิชา',
                                style: GoogleFonts.prompt(color: Colors.grey),
                              ),
                            )
                            : Column(
                              children: [
                                // Header row
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'วิชา',
                                          style: GoogleFonts.prompt(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[700],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'เกรด',
                                          style: GoogleFonts.prompt(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[700],
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                Column(
                                  children: List.generate(subjects.length, (
                                    index,
                                  ) {
                                    final sub = subjects[index];
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  sub['subject_name'] ?? '-',
                                                  style: GoogleFonts.prompt(
                                                    fontSize: 15,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${sub['grade_code']} (${sub['overall_grade']})',
                                                  style: GoogleFonts.prompt(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.blueGrey[800],
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (index != subjects.length - 1)
                                          Divider(
                                            color: Colors.grey[300],
                                            thickness: 1,
                                            height: 0,
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      // Transcript
                      Text(
                        'Transcript',
                        style: GoogleFonts.prompt(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child:
                              transcriptUrl != null && transcriptUrl.isNotEmpty
                                  ? GestureDetector(
                                    onTap:
                                        () => showImageDialog(
                                          context,
                                          transcriptUrl,
                                        ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        transcriptUrl,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Center(
                                            child: Text(
                                              'โหลดรูปไม่ได้',
                                              style: GoogleFonts.prompt(
                                                color: Colors.red,
                                              ),
                                            ),
                                          );
                                        },
                                        loadingBuilder: (
                                          context,
                                          child,
                                          progress,
                                        ) {
                                          if (progress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  : Center(
                                    child: Text(
                                      'ไม่มีรูป Transcript',
                                      style: GoogleFonts.prompt(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      transcriptUrl != null && transcriptUrl.isNotEmpty
                          ? Center(
                            child: Text(
                              'แตะที่รูปเพื่อดูขนาดใหญ่',
                              style: GoogleFonts.prompt(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
