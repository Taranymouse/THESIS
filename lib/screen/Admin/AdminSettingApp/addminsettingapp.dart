import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project/API/api_config.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';

class AdminSettingsPage extends StatefulWidget {
  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  int? currentYear;
  int? currentTerm;
  bool isSystemOpen = false;
  bool isLoading = true;

  late final List<int> years;
  final List<int> terms = [1, 2, 3];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // สมมติปีปัจจุบันเป็น พ.ศ.
    int buddhistYear = now.year + 543;
    years = [buddhistYear - 1, buddhistYear, buddhistYear + 1];
    fetchSettings();
    fetchSystemStatus();
  }

  Future<void> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/setting/getsettings'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int apiYear = data['current_year'];
        int apiTerm = data['current_term'];
        if (!years.contains(apiYear)) apiYear = years[0];
        if (!terms.contains(apiTerm)) apiTerm = terms[0];
        setState(() {
          currentYear = apiYear;
          currentTerm = apiTerm;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSystemStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/setting/get-system-status'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isSystemOpen = data['Settings'];
      });
    }
  }

  Future<void> updateSettings() async {
    await http.put(
      Uri.parse('$baseUrl/api/setting/updateSettings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'current_year': currentYear,
        'current_term': currentTerm,
      }),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('บันทึกสำเร็จ')));
  }

  Future<void> updateSystemStatus(bool value) async {
    setState(() {
      isSystemOpen = value;
    });
    await http.put(
      Uri.parse('$baseUrl/api/setting/Update-system'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Settings': value}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('ตั้งค่าระบบ', style: GoogleFonts.prompt()),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: AdminHomepage()),
        elevation: 0,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.settings,
                              color: ColorPlate.colors[6].color,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'ตั้งค่าระบบ',
                              style: GoogleFonts.prompt(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ColorPlate.colors[6].color,
                              ),
                            ),
                            Divider(height: 32, thickness: 1.2),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: ColorPlate.colors[2].color,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "ปีการศึกษา",
                                  style: GoogleFonts.prompt(fontSize: 16),
                                ),
                                Spacer(),
                                DropdownButton<int>(
                                  value: currentYear,
                                  style: GoogleFonts.prompt(
                                    color: Colors.teal,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items:
                                      years
                                          .map(
                                            (y) => DropdownMenuItem(
                                              value: y,
                                              child: Text('$y'),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) =>
                                          setState(() => currentYear = val!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.school,
                                  color: ColorPlate.colors[2].color,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "ภาคเรียน",
                                  style: GoogleFonts.prompt(fontSize: 16),
                                ),
                                Spacer(),
                                DropdownButton<int>(
                                  value: currentTerm,
                                  style: GoogleFonts.prompt(
                                    color: Colors.teal,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items:
                                      terms
                                          .map(
                                            (t) => DropdownMenuItem(
                                              value: t,
                                              child: Text('เทอม $t'),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) =>
                                          setState(() => currentTerm = val!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                            SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.topSlide,
                                    title: 'ยืนยัน',
                                    titleTextStyle: GoogleFonts.prompt(
                                      fontSize: 20,
                                    ),
                                    desc: 'ต้องการที่จะอัพเดทข้อมูลใช่ไหม ?',
                                    btnOkOnPress: () {
                                      updateSettings();
                                    },
                                    btnCancelOnPress: () {},
                                  ).show();
                                },
                                icon: Icon(Icons.save),
                                label: Text(
                                  'บันทึก',
                                  style: GoogleFonts.prompt(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorPlate.colors[6].color,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                            Divider(thickness: 1.2),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.power_settings_new_rounded,
                                  color:
                                      isSystemOpen
                                          ? Colors.orange
                                          : Colors.grey,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'เปิด/ปิด ระบบ',
                                  style: GoogleFonts.prompt(fontSize: 16),
                                ),
                                Spacer(),
                                Switch(
                                  value: isSystemOpen,
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.topSlide,
                                      title: 'ยืนยัน',
                                      titleTextStyle: GoogleFonts.prompt(
                                        fontSize: 20,
                                      ),
                                      desc:
                                          value
                                              ? 'คุณต้องการ "เปิด" ระบบใช่หรือไม่?'
                                              : 'คุณต้องการ "ปิด" ระบบใช่หรือไม่?',
                                      btnOkOnPress: () {
                                        updateSystemStatus(value);
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                ),
                                Text(
                                  isSystemOpen ? 'เปิด' : 'ปิด',
                                  style: GoogleFonts.prompt(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSystemOpen
                                            ? Colors.orange
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
