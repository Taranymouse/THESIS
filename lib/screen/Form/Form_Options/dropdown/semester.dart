import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';

class Semester extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const Semester({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<Semester> createState() => _SemesterState();
}

class _SemesterState extends State<Semester> {
  late Future<List<AcademicTerm>> _futureTerms;

  @override
  void initState() {
    super.initState();
    _futureTerms = fetchAcademicTerms();
  }

  Future<List<AcademicTerm>> fetchAcademicTerms() async {
    final response = await http.get(Uri.parse('$baseUrl/api/academic_terms'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((e) => AcademicTerm.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load academic terms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AcademicTerm>>(
      future: _futureTerms,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: Colors.red),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('ไม่มีข้อมูลภาคการศึกษา');
        } else {
          final terms = snapshot.data!;
          return DropdownButton<String>(
            hint: Text("-เลือก-", style: GoogleFonts.prompt(fontSize: 8)),
            value: widget.selectedValue,
            items:
                terms.map((term) {
                  return DropdownMenuItem<String>(
                    value: term.nameTerm,
                    child: Text(
                      term.nameTerm,
                      style: GoogleFonts.prompt(fontSize: 12),
                    ),
                  );
                }).toList(),
            onChanged: widget.onChanged,
            isExpanded: true,
            alignment: Alignment.center,
            dropdownColor: Colors.white,
          );
        }
      },
    );
  }
}

class AcademicTerm {
  final int idTerm;
  final String nameTerm;

  AcademicTerm({required this.idTerm, required this.nameTerm});

  factory AcademicTerm.fromJson(Map<String, dynamic> json) {
    return AcademicTerm(idTerm: json['id_term'], nameTerm: json['name_term']);
  }
}
