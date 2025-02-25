import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/screen/Form/checkForm.dart';
import 'package:project/screen/home.dart';
import 'package:project/screen/SignIn/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SemesterBloc()),
        BlocProvider(
          create: (context) => LoginBloc()..add(CheckSessionEvent()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Checkform(),
    );
  }
}
