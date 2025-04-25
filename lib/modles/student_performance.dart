class SubjectGrade {
  final String subjectName;
  final String gradeCode;
  final double credit;
  final double gradePoint;

  SubjectGrade({
    required this.subjectName,
    required this.gradeCode,
    required this.credit,
    required this.gradePoint,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    return SubjectGrade(
      subjectName: json['subject_name'],
      gradeCode: json['grade_code'],
      credit: (json['credit'] as num).toDouble(),
      gradePoint: (json['grade_point'] as num).toDouble(),
    );
  }
}

class StudentGradeGroup {
  final int idStudent;
  final String firstName;
  final String lastName;
  final String codeStudent;
  final int year;
  final String termName;
  final double overallGrade;
  final String label;
  final List<SubjectGrade> subjectGrades;

  StudentGradeGroup({
    required this.idStudent,
    required this.firstName,
    required this.lastName,
    required this.codeStudent,
    required this.year,
    required this.termName,
    required this.overallGrade,
    required this.label,
    required this.subjectGrades,
  });

  factory StudentGradeGroup.fromJson(Map<String, dynamic> json) {
    final head = json['head_info'] ?? {};
    return StudentGradeGroup(
      idStudent: json['id_student'],
      firstName: head['first_name'],
      lastName: head['last_name'],
      codeStudent: head['code_student'],
      year: head['year'],
      termName: head['term_name'],
      overallGrade: double.tryParse(json['overall_grade'].toString()) ?? 0.0,
      label: json['label'] ?? '',
      subjectGrades: (json['head_info'] as List)
          .map((e) => SubjectGrade.fromJson(e))
          .toList(),
    );
  }
}
