import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/bloc/Course/course_bloc.dart';
import 'package:project/bloc/CourseYear/courseyear_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/bloc/StdYear/stdyear_bloc.dart';
import 'package:project/bloc/Subject/CS/subject_cs_bloc.dart';
import 'package:project/bloc/Subject/IT/subject_bloc.dart';
import 'package:project/screen/Form/checkForm.dart';
import 'package:project/screen/Form/dropdown/courseyear.dart';
import 'package:project/screen/home.dart';
import 'package:project/screen/SignIn/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SemesterBloc()),
        BlocProvider(create: (context) => CourseBloc()),
        BlocProvider(create: (context) => CourseyearBloc()),
        BlocProvider(create: (context) => StdyearBloc()),
        BlocProvider(
          create: (context) => LoginBloc()..add(CheckSessionEvent()),
        ),
        BlocProvider(create: (context) => SubjectBloc()),
        BlocProvider(create: (context) => SubjectCsBloc()),
        BlocProvider(create: (context) => BottomNavBloc()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.kanit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: GoogleFonts.kanit(),
          bodySmall: GoogleFonts.kanit(),
        ),
      ),
      home: Checkform(),
    );
  }
}
