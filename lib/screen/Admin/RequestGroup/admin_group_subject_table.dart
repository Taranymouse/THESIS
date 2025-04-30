import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/student_performance.dart';

class AdminGroupSubjectTable extends StatefulWidget {
  final List<int> studentIds;

  const AdminGroupSubjectTable({super.key, required this.studentIds});

  @override
  State<AdminGroupSubjectTable> createState() =>
      _AdminGroupSubjectTableleState();
}

class _AdminGroupSubjectTableleState extends State<AdminGroupSubjectTable> {
  late Future<void> _loadingFuture;
  List<StudentGradeGroup> studentGrades = [];

  @override
  void initState() {
    super.initState();
    _loadingFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final headResponse = await http.post(
      Uri.parse('$baseUrl/api/check/group-head-calculate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(widget.studentIds),
    );

    final subjectResponse = await http.post(
      Uri.parse('$baseUrl/api/check/group-subject-calculate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(widget.studentIds),
    );

    print('Head Response: ${utf8.decode(headResponse.bodyBytes)}');
    print('Subject Response: ${utf8.decode(subjectResponse.bodyBytes)}');

    if (headResponse.statusCode == 200 && subjectResponse.statusCode == 200) {
      final headJson = jsonDecode(utf8.decode(headResponse.bodyBytes)) as List;
      final subjectJson =
          jsonDecode(utf8.decode(subjectResponse.bodyBytes)) as List;

      studentGrades =
          subjectJson.map((subjectEntry) {
            final idStudent = subjectEntry['id_student'];
            final label = subjectEntry['label'];
            final overallGrade =
                double.tryParse(subjectEntry['overall_grade'] ?? "0.0") ?? 0.0;

            // หาข้อมูลจาก headResponse
            final headEntry = headJson.firstWhere(
              (e) => e['id_student'] == idStudent,
              orElse: () => null,
            );
            final headInfo = headEntry != null ? headEntry['head_info'] : null;

            final subjects =
                (subjectEntry['head_info'] as List).map((s) {
                  return SubjectGrade(
                    subjectName: s['subject_name'],
                    gradeCode: s['grade_code'],
                    credit: (s['credit'] as num).toDouble(),
                    gradePoint: (s['grade_point'] as num).toDouble(),
                  );
                }).toList();

            return StudentGradeGroup(
              idStudent: idStudent,
              codeStudent: headInfo?['code_student'] ?? '',
              firstName: headInfo?['first_name'] ?? '',
              lastName: headInfo?['last_name'] ?? '',
              termName: headInfo?['term_name'] ?? '',
              year: headInfo?['year'] ?? '',
              subjectGrades: subjects,
              label: label,
              overallGrade: overallGrade,
            );
          }).toList();
    } else {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        } else if (studentGrades.isEmpty) {
          return Center(
            child: Text(
              '* นักศึกษายังไม่ได้ทำแบบตรวจสอบคุณสมบัติในการมีสิทธิ์ขอจัดทำโครงงานปริญญานิพนธ์ (IT00G / CS00G)',
              style: GoogleFonts.prompt(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final List<double> individualScores = [];

        for (var student in studentGrades) {
          final totalScore = student.subjectGrades.fold<double>(0.0, (
            sum,
            subject,
          ) {
            return sum + (subject.gradePoint * subject.credit);
          });
          individualScores.add(totalScore);
        }

        final totalAll = individualScores.fold(0.0, (a, b) => a + b);
        final averageGroupScore = totalAll / individualScores.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.lightBlue[50],
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "คะแนนเฉลี่ยของกลุ่ม: ${averageGroupScore.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            ...List.generate(studentGrades.length, (index) {
              final student = studentGrades[index];
              final totalScore = individualScores[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${student.firstName} ${student.lastName} (${student.codeStudent})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'คะแนนรวม: ${totalScore.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'เกรดเฉลี่ย: ${student.overallGrade.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Center(
                    child: Text(
                      ' ภาคเรียน ${student.termName} ปีการศึกษา ${student.year}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            'รหัสวิชา - ชื่อวิชา',
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'เกรด',
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'คะแนน',
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ],
                      rows:
                          student.subjectGrades.map((subject) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.35,
                                    child: Text(
                                      subject.subjectName,
                                      style: const TextStyle(fontSize: 8),
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    subject.gradeCode,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    (subject.gradePoint * subject.credit)
                                        .toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                    Text(
                      'เกรดเฉลี่ย: ${student.overallGrade.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
