class Subject {
  final int id_subject;
  final String courseCode;
  final String name_subjects;
  final String year;
  final int branchId;
  final String branchName;

  Subject({
    required this.id_subject,
    required this.courseCode,
    required this.name_subjects,
    required this.year,
    required this.branchId,
    required this.branchName,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id_subject: json['id_subject'] ?? 0,
      courseCode: json['course_code'] ?? 'N/A',
      name_subjects: json['name_subjects'] ?? 'Unknown Subject',
      year: json['year_course_sub'] ?? 'Unknown Year',
      branchId: json['id_branch'] ?? 0,
      branchName:
          json['branch'] != null && json['branch']['name_branch'] != null
              ? json['branch']['name_branch']
              : 'Unknown Branch',
    );
  }
}
