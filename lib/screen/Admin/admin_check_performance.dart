import 'package:flutter/material.dart';

class Student {
  final String studentId;
  final String firstName;
  final String lastName;
  final String course;
  final int year;
  final String advisor;
  final List<Subject> subjects;

  Student({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.course,
    required this.year,
    required this.advisor,
    required this.subjects,
  });
}

class Subject {
  final String subjectCode;
  final String subjectName;
  final int credits;
  final double midtermScore;
  final double finalScore;
  final double assignmentScore;

  Subject({
    required this.subjectCode,
    required this.subjectName,
    required this.credits,
    required this.midtermScore,
    required this.finalScore,
    required this.assignmentScore,
  });
}

class StudentListPage extends StatelessWidget {
  final List<Student> students = [
    Student(
      studentId: '64070001',
      firstName: 'Somchai',
      lastName: 'Suksai',
      course: 'Computer Science',
      year: 3,
      advisor: 'Dr. Arun',
      subjects: [
        Subject(
          subjectCode: 'SIT101',
          subjectName: 'Computer Programming',
          credits: 4,
          midtermScore: 10,
          finalScore: 10,
          assignmentScore: 15,
        ),
        Subject(
          subjectCode: 'SIT102',
          subjectName: 'Data Structure',
          credits: 3,
          midtermScore: 8,
          finalScore: 9,
          assignmentScore: 12,
        ),
      ],
    ),
    Student(
      studentId: '64070002',
      firstName: 'Anong',
      lastName: 'Chaiyaporn',
      course: 'Information Technology',
      year: 2,
      advisor: 'Dr. Somchai',
      subjects: [
        Subject(
          subjectCode: 'SIT211',
          subjectName: 'Database',
          credits: 3,
          midtermScore: 7,
          finalScore: 8,
          assignmentScore: 10,
        ),
        Subject(
          subjectCode: 'SIT212',
          subjectName: 'Networking',
          credits: 4,
          midtermScore: 9,
          finalScore: 9,
          assignmentScore: 13,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายชื่อนักศึกษา'),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('${student.firstName} ${student.lastName}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailPage(student: student),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class StudentDetailPage extends StatelessWidget {
  final Student student;

  const StudentDetailPage({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalCredits = 0;
    double totalScore = 0;
    for (var subject in student.subjects) {
      totalCredits += subject.credits;
      totalScore += subject.midtermScore + subject.finalScore + subject.assignmentScore;
    }
    double gpa = totalScore / totalCredits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดนักศึกษา'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('รหัสนักศึกษา: ${student.studentId}'),
            Text('ชื่อ: ${student.firstName} ${student.lastName}'),
            Text('สาขา: ${student.course}'),
            Text('ปี: ${student.year}'),
            const SizedBox(height: 20),
            const Text('รายวิชา:'),
            Expanded(
              child: ListView.builder(
                itemCount: student.subjects.length,
                itemBuilder: (context, index) {
                  final subject = student.subjects[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('รหัสวิชา: ${subject.subjectCode}'),
                          Text('ชื่อวิชา: ${subject.subjectName}'),
                          Text('หน่วยกิต: ${subject.credits}'),
                          Text('คะแนนกลางภาค: ${subject.midtermScore}'),
                          Text('คะแนนปลายภาค: ${subject.finalScore}'),
                          Text('คะแนนงาน: ${subject.assignmentScore}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('รวมหน่วยกิต: $totalCredits'),
            Text('เกรดเฉลี่ย: ${gpa.toStringAsFixed(2)}'),
            Text('อาจารย์ที่ปรึกษา: ${student.advisor}'),
          ],
        ),
      ),
    );
  }
}
