import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Student/document_router.dart';

// Model Classes (เหมือนเดิม)
class Bachelor {
  final int id;
  final String name;
  final int year;
  Bachelor({required this.id, required this.name, required this.year});
  factory Bachelor.fromJson(Map<String, dynamic> json) => Bachelor(
    id: json['id_bachelor'] as int,
    name: json['name_bachelor'] as String,
    year: json['year_bachelor'] as int,
  );
}

class Prefix {
  final int id;
  final String name;
  Prefix({required this.id, required this.name});
  factory Prefix.fromJson(Map<String, dynamic> j) =>
      Prefix(id: j['id_prefix'] as int, name: j['name_prefix'] as String);
}

class Subject {
  final int id;
  final String code;
  final String name;
  final double credit;
  Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.credit,
  });
  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
    id: j['id_subject'] as int,
    code: j['course_code'] as String,
    name: j['name_subjects'] as String,
    credit: (j['credit'] as num).toDouble(),
  );
}

class Grade {
  final int id;
  final String code;
  final double point;
  Grade({required this.id, required this.code, required this.point});
  factory Grade.fromJson(Map<String, dynamic> j) => Grade(
    id: j['id_grade'] as int,
    code: j['grade_code'] as String,
    point: (j['grade_point'] as num).toDouble(),
  );
}

class Term {
  final int id;
  final String name;
  Term({required this.id, required this.name});
  factory Term.fromJson(Map<String, dynamic> j) =>
      Term(id: j['id_term'] as int, name: j['name_term'] as String);
}

// Main Form Page
class ProjectFormPage extends StatefulWidget {
  @override
  _ProjectFormPageState createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  List<Bachelor> bachelors = [];
  List<Prefix> prefixes = [];
  List<Grade> grades = [];
  List<Term> terms = [];

  Bachelor? selectedBachelor;
  List<StudentForm> studentForms = [StudentForm(key: UniqueKey())];

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchBachelors(),
      fetchPrefixes(),
      fetchGrades(),
      fetchTerms(),
    ]);
  }

  Future<void> fetchBachelors() async {
    final res = await http.get(Uri.parse('$baseUrl/api/Bachelor'));
    print('fetchBachelors status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final jsonStr = utf8.decode(res.bodyBytes);
      print('bachelors json: $jsonStr');
      final list = jsonDecode(jsonStr) as List;
      setState(
        () => bachelors = list.map((e) => Bachelor.fromJson(e)).toList(),
      );
      print('loaded bachelors count: ${bachelors.length}');
    }
  }

  Future<void> fetchPrefixes() async {
    final res = await http.get(Uri.parse('$baseUrl/api/prefix'));
    print('fetchPrefixes status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final jsonStr = utf8.decode(res.bodyBytes);
      print('prefixes json: $jsonStr');
      final list = jsonDecode(jsonStr) as List;
      setState(() => prefixes = list.map((e) => Prefix.fromJson(e)).toList());
      print('loaded prefixes count: ${prefixes.length}');
    }
  }

  Future<void> fetchGrades() async {
    final res = await http.get(Uri.parse('$baseUrl/api/grades'));
    print('fetchGrades status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final jsonStr = utf8.decode(res.bodyBytes);
      print('grades json: $jsonStr');
      final list = jsonDecode(jsonStr) as List;
      setState(() => grades = list.map((e) => Grade.fromJson(e)).toList());
      print('loaded grades count: ${grades.length}');
    }
  }

  Future<void> fetchTerms() async {
    final res = await http.get(Uri.parse('$baseUrl/api/academic_terms'));
    print('fetchTerms status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final jsonStr = utf8.decode(res.bodyBytes);
      print('terms json: $jsonStr');
      final list = jsonDecode(jsonStr) as List;
      setState(() => terms = list.map((e) => Term.fromJson(e)).toList());
      print('loaded terms count: ${terms.length}');
    }
  }

  void addStudent() {
    if (studentForms.length < 3) {
      setState(() => studentForms.add(StudentForm(key: UniqueKey())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ฟอร์มขอจัดทำโครงงาน'),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: DocumentRouter()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Bachelor>(
              decoration: InputDecoration(labelText: 'หลักสูตร'),
              isExpanded: true,
              value: selectedBachelor,
              items:
                  bachelors
                      .map(
                        (b) => DropdownMenuItem(value: b, child: Text(b.name)),
                      )
                      .toList(),
              onChanged: (b) {
                print('selectedBachelor: ${b?.name}');
                setState(() => selectedBachelor = b);
              },
            ),
            ...studentForms,
            Row(
              children: [
                ElevatedButton(
                  onPressed: addStudent,
                  child: Text('เพิ่มสมาชิก'),
                ),
                Spacer(),
                ElevatedButton(onPressed: () {}, child: Text('ส่งแบบฟอร์ม')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StudentData {
  int? prefixId;
  String firstName = '';
  String lastName = '';
  String studentId = '';
  int? termId;
  int? year;
  Map<int, double> subjectGrades = {};
}

class StudentForm extends StatefulWidget {
  const StudentForm({Key? key}) : super(key: key);
  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  int offset = 0, limit = 10;
  final data = StudentData();

  List<Prefix> get prefixes =>
      context.findAncestorStateOfType<_ProjectFormPageState>()!.prefixes;
  List<Grade> get grades =>
      context.findAncestorStateOfType<_ProjectFormPageState>()!.grades;
  List<Term> get terms =>
      context.findAncestorStateOfType<_ProjectFormPageState>()!.terms;
  Bachelor? get selectedBachelor =>
      context
          .findAncestorStateOfType<_ProjectFormPageState>()!
          .selectedBachelor;

  List<Subject> subjects = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    print(
      'StudentForm fetchSubjects offset=$offset, bachelor=${selectedBachelor?.id}',
    );
    if (selectedBachelor == null) return;
    final url =
        '$baseUrl/api/subjects?offset=$offset&limit=$limit&course=${selectedBachelor!.id}&course_year=${selectedBachelor!.year}';
    final res = await http.get(Uri.parse(url));
    print('fetchSubjects status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final jsonStr = utf8.decode(res.bodyBytes);
      print('subjects json: $jsonStr');
      final body = jsonDecode(jsonStr);
      setState(
        () =>
            subjects =
                (body['data'] as List).map((e) => Subject.fromJson(e)).toList(),
      );
      print('loaded subjects count: ${subjects.length}');
    }
  }

  double calculateGPA() {
    double tp = 0, tc = 0;
    data.subjectGrades.forEach((id, pt) {
      final s = subjects.firstWhere((e) => e.id == id);
      tp += pt * s.credit;
      tc += s.credit;
    });
    return tc > 0 ? tp / tc : 0;
  }

  @override
  Widget build(BuildContext ctx) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prefix
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'คำนำหน้า'),
              isExpanded: true,
              value: data.prefixId,
              items:
                  prefixes
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
              onChanged: (v) => setState(() => data.prefixId = v),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'ชื่อ'),
              onChanged: (v) => data.firstName = v,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'นามสกุล'),
              onChanged: (v) => data.lastName = v,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'รหัสนักศึกษา'),
              onChanged: (v) => data.studentId = v,
            ),
            SizedBox(height: 12),
            // Subjects table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('รหัส')),
                  DataColumn(label: Text('รายวิชา')),
                  DataColumn(label: Text('หน่วยกิต')),
                  DataColumn(label: Text('ภาค')),
                  DataColumn(label: Text('ปี')),
                  DataColumn(label: Text('เกรด')),
                ],
                rows:
                    subjects.map((s) {
                      final pt = data.subjectGrades[s.id];
                      return DataRow(
                        cells: [
                          DataCell(Text(s.code)),
                          DataCell(Text(s.name)),
                          DataCell(Text(s.credit.toString())),
                          DataCell(
                            DropdownButton<int>(
                              isExpanded: true,
                              value: data.termId,
                              items:
                                  terms
                                      .map(
                                        (t) => DropdownMenuItem(
                                          value: t.id,
                                          child: Text(t.name),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) => setState(() => data.termId = v),
                            ),
                          ),
                          DataCell(
                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: data.year?.toString() ?? '',
                              ),
                              onSubmitted:
                                  (v) => setState(
                                    () => data.year = int.tryParse(v),
                                  ),
                            ),
                          ),
                          DataCell(
                            DropdownButton<double>(
                              isExpanded: true,
                              value: pt,
                              items:
                                  grades
                                      .map(
                                        (g) => DropdownMenuItem(
                                          value: g.point,
                                          child: Text(g.code),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (v) => setState(
                                    () => data.subjectGrades[s.id] = v!,
                                  ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
            // Pagination
            Row(
              children: [
                ElevatedButton(
                  onPressed:
                      offset >= limit
                          ? () => setState(() {
                            offset -= limit;
                            fetchSubjects();
                          })
                          : null,
                  child: Text('ก่อนหน้า'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed:
                      subjects.length == limit
                          ? () => setState(() {
                            offset += limit;
                            fetchSubjects();
                          })
                          : null,
                  child: Text('ถัดไป'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('GPA: ${calculateGPA().toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
