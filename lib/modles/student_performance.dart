class SubjectGrade {
  final String subjectName;
  final String termName;
  final int year;
  final String gradeCode;
  final String overallGrade;

  SubjectGrade({
    required this.subjectName,
    required this.termName,
    required this.year,
    required this.gradeCode,
    required this.overallGrade,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    return SubjectGrade(
      subjectName: json['subject_name'],
      termName: json['term_name'],
      year: json['year'],
      gradeCode: json['grade_code'],
      overallGrade: json['overall_grade'],
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
  final List<SubjectGrade> subjectGrades;

  StudentGradeGroup({
    required this.idStudent,
    required this.firstName,
    required this.lastName,
    required this.codeStudent,
    required this.year,
    required this.termName,
    required this.subjectGrades,
  });

  factory StudentGradeGroup.fromJson(Map<String, dynamic> json) {
    return StudentGradeGroup(
      idStudent: json['id_student'],
      firstName: json['head_info']['first_name'],
      lastName: json['head_info']['last_name'],
      codeStudent: json['head_info']['code_student'],
      year: json['head_info']['year'],
      termName: json['head_info']['term_name'],
      subjectGrades: List<SubjectGrade>.from(
        json['subject_grades'].map((e) => SubjectGrade.fromJson(e)),
      ),
    );
  }
}
