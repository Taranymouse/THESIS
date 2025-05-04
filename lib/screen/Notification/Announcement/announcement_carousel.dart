import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project/screen/Notification/notification.dart';

class AnnouncementCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> pinnedAnnouncements;

  const AnnouncementCarousel({Key? key, required this.pinnedAnnouncements})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: pinnedAnnouncements.isNotEmpty
          ? pinnedAnnouncements.map((post) {
              return Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnnouncementDetailPage(post: post),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (post['image_url'] != null &&
                                post['image_url'].toString().isNotEmpty)
                              Image.network(
                                post['image_url'],
                                fit: BoxFit.cover,
                              ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Text(
                                post['title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList()
          : [
              Builder(
                builder: (context) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            "กำลังโหลดประกาศ...",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
    );
  }
}
