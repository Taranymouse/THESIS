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
import 'package:project/bloc/Subject/IT/subject_repository.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Admin/admin_check_performance.dart';
import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Admin/ManageSubject/createsubject.dart';
import 'package:project/screen/Profeser/profhome.dart';
import 'package:project/screen/SignIn/create_student.dart';
import 'package:project/screen/SignIn/login.dart';
import 'package:project/screen/SignIn/set_password_screen.dart';
import 'package:project/screen/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final sessionService = SessionService();
  final isLoggedIn = await sessionService.isLoggedIn();
  final userRole = isLoggedIn ? await sessionService.getUserRole() : null;
  print("Role on main: $userRole");

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
        BlocProvider(create: (context) => SubjectBloc(SubjectRepository())),
        BlocProvider(create: (context) => SubjectCsBloc()),
        BlocProvider(create: (context) => BottomNavBloc()),
        BlocProvider(create: (context) => GetSubjectBloc()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn, userRole: userRole),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userRole;

  const MyApp({super.key, required this.isLoggedIn, this.userRole});

  @override
  Widget build(BuildContext context) {
    String initialRoute;

    if (!isLoggedIn) {
      initialRoute = '/login';
    } else {
      switch (userRole) {
        case '1':
          initialRoute = '/home';
          break;
        case '4':
          initialRoute = '/admin-home';
          break;
        default:
          initialRoute = '/login';
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => Homepage(),
        '/admin-home': (context) => AdminHomepage(),
        '/prof-home': (context) => ProfHomepage(),
        '/set-password': (context) => SetPasswordScreen(),
        '/create-student': (context) => CreateStudentScreen(),
        '/createsubject': (context) => Createsubject(),
      },
    );
  }
}
