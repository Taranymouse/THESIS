class Subject {
  final int idSubject;
  final String courseCode;
  final String nameSubjects;
  final String yearCourseSub;
  final int idBranch;
  final String branchName;

  Subject({
    required this.idSubject,
    required this.courseCode,
    required this.nameSubjects,
    required this.yearCourseSub,
    required this.idBranch,
    required this.branchName,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      idSubject: json['id_subject'] ?? 0,
      courseCode: json['course_code'] ?? 'N/A', // กำหนดค่าเริ่มต้นหากเป็น null
      nameSubjects: json['name_subjects'] ?? 'Unknown Subject',
      yearCourseSub: json['year_course_sub'] ?? 'Unknown Year',
      idBranch: json['id_branch'] ?? 0,
      branchName: json['branch']?['name_branch'] ?? 'Unknown Branch',
    );
  }
}
