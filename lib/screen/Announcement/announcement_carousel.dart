import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project/ColorPlate/color.dart';

class AnnouncementCarousel extends StatelessWidget {
  const AnnouncementCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> announcements = [
      "📌 ประกาศปิดรับสมัครโครงงานสิ้นเดือนนี้!",
      "⚠️ การสอบกลางภาคจะจัดขึ้นสัปดาห์หน้า",
      "🎓 ขอแสดงความยินดีกับนักศึกษาที่ได้รับทุนการศึกษา"
    ];

    return Column(
      children: [
        Text(
          "📢 ประกาศสำคัญ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        CarouselSlider.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AnnouncementDetailPage(
                      announcement: announcements[index],
                      index: index,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'announcement_$index',
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: ColorPlate.colors[0].color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        announcements[index],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 10),
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.9,
          ),
        ),
      ],
    );
  }
}

class AnnouncementDetailPage extends StatelessWidget {
  final String announcement;
  final int index;

  const AnnouncementDetailPage({super.key, required this.announcement, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(announcement)),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "รายละเอียดเพิ่มเติมของประกาศนี้...",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
