import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/modles/subject_model.dart';

class SubjectRepository {
  Future<List<Subject>> getSubjects({int offset = 0, int limit = 10}) async {
    final response = await http.get(Uri.parse('http://192.168.1.108:8000/api/subjects?offset=$offset&limit=$limit'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body); // รับเป็น Map
      final List<dynamic> subjectsData = data['data']; // เข้าถึง key 'data' ที่เก็บ List ของ subjects
      return subjectsData.map((json) => Subject.fromJson(json)).toList(); // map เป็น list ของ Subject
    } else {
      throw Exception('Failed to load subjects');
    }
  }
}
