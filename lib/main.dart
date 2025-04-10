import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/bloc/Course/course_bloc.dart';
import 'package:project/bloc/CourseYear/courseyear_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';
import 'package:project/bloc/GetSubject/get_subject_bloc.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/bloc/StdYear/stdyear_bloc.dart';
import 'package:project/bloc/Subject/CS/subject_cs_bloc.dart';
import 'package:project/bloc/Subject/IT/subject_bloc.dart';
import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Form/CheckPerForm/checkPerForm.dart';
import 'package:project/screen/ManageSubject/createsubject.dart';
import 'package:project/screen/ManageSubject/fetchallsubject.dart';
import 'package:project/screen/Form/checkForm.dart';
import 'package:project/screen/SignIn/login.dart';
import 'package:project/screen/SignIn/setpassword.dart';
import 'package:project/screen/home.dart';
import 'package:project/modles/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ตรวจสอบสถานะการเข้าสู่ระบบ
  final sessionService = SessionService();
  final isLoggedIn = await sessionService.isLoggedIn();

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
        BlocProvider(create: (context) => GetSubjectBloc()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.prompt(fontSize: 20),
          bodyMedium: GoogleFonts.prompt(),
          bodySmall: GoogleFonts.prompt(),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.prompt(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      // home: AllSubjectsPage(),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => Homepage(),
        '/admin-home': (context) => AdminHomepage(),
        '/set-password':
            (context) => SetPasswordScreen(
              email: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/createsubject': (context) => Createsubject(),
      },
    );
  }
}
