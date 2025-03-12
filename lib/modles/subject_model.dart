class Subject {
  final int id;
  final String courseCode;
  final String name;
  final String year;
  final int branchId;
  final String branchName;

  Subject({
    required this.id,
    required this.courseCode,
    required this.name,
    required this.year,
    required this.branchId,
    required this.branchName,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id_subject'],
      courseCode: json['course_code'],
      name: json['name_subjects'],
      year: json['year_course_sub'],
      branchId: json['id_branch'],
      branchName: json['name_branch'],
    );
  }
}
