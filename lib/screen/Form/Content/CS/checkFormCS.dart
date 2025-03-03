import 'package:flutter/material.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/screen/Form/TextFeild/customTextFeild.dart';

class CSFormContent extends StatelessWidget {

  const CSFormContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: ColorPlate.colors[2].color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ผลการเรียนรายวิชาบังคับของหลักสูตรในชั้นปีที่ 1-3 ที่เป็นหลักสูตรของภาควิชาฯ (รายวิชาที่ขึ้นต้นรหัสด้วย 517 และ 520)",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              ExpansionTile(
                title: Text('520101 วิชาทดลอง CS'),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(width: 5),
                      DropdownButton<String>(
                        hint: Text("ปีการศึกษา"),
                        items:
                            ['2567', '2568'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (value) {},
                      ),
                      SizedBox(width: 5),
                      DropdownButton<String>(
                        hint: Text("เกรด"),
                        items:
                            ['A', 'B', 'C', 'D'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
