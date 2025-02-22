import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';
import 'package:project/screen/home.dart';
import 'package:project/screen/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              LoginBloc()
                ..add(CheckSessionEvent()), // ✅ เพิ่ม Event เช็ก Session
      child: MaterialApp(
        title: 'Project',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state is LoginSuccess) {
              return const Homepage(); // ✅ ถ้า Login สำเร็จให้ไปหน้า Home
            } else if (state is LoginLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              ); // 👉 แสดง Loading ระหว่างเช็ก Session
            } else {
              return Login(); // ✅ ถ้าไม่ได้ล็อกอินให้แสดงหน้า Login
            }
          },
        ),
        routes: {
          '/login': (context) => Login(),
          '/home': (context) => const Homepage(),
        },
      ),
    );
  }
}
