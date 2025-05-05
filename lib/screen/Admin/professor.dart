import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';

class ProfessorScreen extends StatefulWidget {
  const ProfessorScreen({super.key});

  @override
  State<ProfessorScreen> createState() => _ProfessorScreenState();
}

class _ProfessorScreenState extends State<ProfessorScreen> {
  int offset = 0;
  int limit = 5;
  String searchQuery = '';
  bool isLoading = false;
  List<Map<String, dynamic>> professors = [];
  Map<String, List<Map<String, dynamic>>> groupedProfessors = {};
  int total = 0;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfessors();
  }

  Future<void> fetchProfessors() async {
    setState(() => isLoading = true);
    try {
      final uri = Uri.parse('$baseUrl/api/professor/').replace(
        queryParameters: {
          'offset': offset.toString(),
          'limit': limit.toString(),
          if (searchQuery.isNotEmpty) 'search': searchQuery,
        },
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonRes = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        setState(() {
          professors = List<Map<String, dynamic>>.from(jsonRes['data'] ?? []);
          total = jsonRes['pagination']['total'] ?? 0;

          groupedProfessors = {};
          for (var prof in professors) {
            final group = prof['group']?['group_name'] ?? 'ไม่ระบุกลุ่ม';
            groupedProfessors.putIfAbsent(group, () => []).add(prof);
          }

          isLoading = false;
        });
      } else {
        throw Exception('โหลดข้อมูลไม่สำเร็จ: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  void onSearch(String value) {
    setState(() {
      offset = 0;
      searchQuery = value;
    });
    fetchProfessors();
  }

  void nextPage() {
    if (offset + limit < total) {
      setState(() => offset += limit);
      fetchProfessors();
    }
  }

  void prevPage() {
    if (offset - limit >= 0) {
      setState(() => offset -= limit);
      fetchProfessors();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("อาจารย์"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: AdminHomepage()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "ค้นหาอาจารย์...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => onSearch(searchController.text),
                ),
              ),
              onSubmitted: onSearch,
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child:
                    groupedProfessors.isEmpty
                        ? const Center(child: Text("ไม่พบข้อมูลอาจารย์"))
                        : ListView(
                          children:
                              groupedProfessors.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ...entry.value.map(
                                      (prof) => Card(
                                        child: ListTile(
                                          title: Text(
                                            '${prof['prefix']?['name_prefix'] ?? ''} ${prof['fname'] ?? ''} ${prof['lname'] ?? ''}',
                                          ),
                                          subtitle: Text(
                                            prof['email'] ?? 'ไม่มีอีเมล',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: offset > 0 ? prevPage : null,
                  child: const Text("ก่อนหน้า"),
                ),
                Text(
                  "แสดง ${offset + 1} - ${offset + professors.length} จากทั้งหมด $total",
                ),
                ElevatedButton(
                  onPressed: offset + limit < total ? nextPage : null,
                  child: const Text("ถัดไป"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
