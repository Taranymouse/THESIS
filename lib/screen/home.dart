import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/Nav/sidebar.dart';
import 'package:project/bloc/Login/login_bloc.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IT/CS THESIS'), centerTitle: true),
      drawer: SideBar(),
      body: Container(
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kanit',
                    ),
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
      ),
    );
  }
}
