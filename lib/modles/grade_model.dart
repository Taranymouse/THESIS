class Grade {
  final int id;
  final String code;
  final String point;

  Grade({
    required this.id,
    required this.code,
    required this.point,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id_grade'],
      code: json['grade_code'],
      point: json['grade_point'],
    );
  }
}
