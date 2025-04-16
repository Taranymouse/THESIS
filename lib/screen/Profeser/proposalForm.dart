import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Profeser/ProfHome.dart';

class Proposalform extends StatefulWidget {
  const Proposalform({super.key});

  @override
  State<Proposalform> createState() => _ProposalformState();
}

class _ProposalformState extends State<Proposalform> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("แบบฟอร์มตรวจคุณสมบัติ"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: ProfHomepage()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "แบบฟอร์มตรวจคุณสมบัติ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "กรุณากรอกข้อมูลให้ครบถ้วน",
                style: TextStyle(fontSize: 18),
              ),
            ),
            // Add your form fields here
          ],
        ),
      ),
    );
  }
}