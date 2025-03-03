import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/Nav/bottom_nav.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Center(child: Text("🔔 แจ้งเตือน", style: TextStyle(fontSize: 24))),
      const HomepageContent(),
      Center(child: Text("⚙️ ตั้งค่า", style: TextStyle(fontSize: 24))),
    ];

    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        int currentIndex = (state is CurrentPage) ? state.currentIndex : 1;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'IT/CS THESIS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: IndexedStack(index: currentIndex, children: pages),
          bottomNavigationBar: BottomNav(),
        );
      },
    );
  }
}

//แยก Widget เพื่อให้ Code อ่านง่าย
class HomepageContent extends StatelessWidget {
  const HomepageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          // แสดง Email ที่ล็อกอิน
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoginSuccess) {
                return Text(
                  "ยินดีต้อนรับ: ${state.displayName}",
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              } else {
                return const Text("ยินดีต้อนรับ: none displayname");
              }
            },
          ),
          Text("ประกาศสำคัญ"),
          SizedBox(height: 20),
          Text("เมนู"),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
