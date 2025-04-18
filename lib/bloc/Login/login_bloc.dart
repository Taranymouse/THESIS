import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:project/modles/session_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SessionService _sessionService = SessionService();

  late final String baseUrl;

  LoginBloc() : super(LoginInitial()) {
    on<LoginWithEmailPassword>(_onLoginWithEmailPassword);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<CheckSessionEvent>(_onCheckSession);
    on<LogoutEvent>(_onLogout);
    on<SetNewPasswordEvent>(_onSetNewPassword);

  }

  // ✅ ---- 1. เช็ก Session เมื่อเปิดแอป ----
  Future<void> _onCheckSession(
    CheckSessionEvent event,
    Emitter<LoginState> emit,
  ) async {
    final String? email = await _sessionService.getUserSession();
    if (email != null) {
      final User? user = _auth.currentUser;
      final String displayName = user?.displayName ?? "No Name";
      emit(LoginSuccess(email, displayName, '')); // 🌟 เพิ่ม Display Name
    } else {
      emit(LoginInitial());
    }
  }

  // 📧 ---- 2. Login with Email & Password ----
  Future<void> _onLoginWithEmailPassword(
    LoginWithEmailPassword event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final User? user = userCredential.user;
      if (user == null || user.email == null) {
        emit(const LoginFailure("Failed to retrieve user data."));
        return;
      }

      final String displayName = user.displayName ?? "No Name";

      await _sessionService.saveEmailSession(user.email!);

      await Future.delayed(Duration(seconds: 2));
      emit(
        LoginSuccess(user.email!, displayName, ''),
      ); // 🌟 ส่ง Display Name กลับไป
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  // 🔑 ---- 3. Login with Google ----
  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(const LoginFailure("Google Sign-In Canceled"));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user == null || user.email == null) {
        emit(const LoginFailure("Failed to retrieve Google account."));
        return;
      }

      final String displayName = user.displayName ?? "No Name";
      final String email = user.email!;
      final String? idToken = await user.getIdToken();

      print("Google ID Token: $idToken");

      // 📌 เรียก API `/login`
      final response = await http.post(
        Uri.parse('http://192.168.1.108:8000/api/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      print("Response Body : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? token = data["token"]; // ✅ ดึง Token จาก API
        late String? role = '';

        await _sessionService.saveAuthToken(token!);

        if (token != null) {
          final response = await http.get(
            Uri.parse('http://192.168.1.108:8000/api/auth/user'),
            headers: {"Authorization": "$token"},
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            role = data['id_role'].toString();
            print("✅ Can Get Role");
          } else {
            print("📌 Error to Get Role");
          }

          // 📌 บันทึก Token & Role ลง Storage
          await _sessionService.saveAuthToken(token);
          print("📌After Get Role : $role");
          emit(LoginSuccess(email, displayName, role));
          if (state is LoginSuccess) {
            await SessionService().saveAuthToken(token);
          }
        } else {
          emit(LoginFailure("Login failed: No token received"));
        }
      } else {
        emit(LoginFailure("Login Failed: ${response.body}"));
      }
    } catch (e) {
      emit(LoginFailure("Google Sign-In Failed: ${e.toString()}"));
    }
  }

  // 🛠 ---- 4. Set New Password ----
  Future<void> _onSetNewPassword(
    SetNewPasswordEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.108:8000/api/users/set-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": event.email, "password": event.password}),
      );

      if (response.statusCode == 200) {
        emit(SetPasswordSuccess());
      } else {
        emit(
          SetPasswordFailure("Failed to set new password: ${response.body}"),
        );
      }
    } catch (e) {
      emit(SetPasswordFailure("Error: ${e.toString()}"));
    }
  }

  // 🚪 ---- 5. Logout ----
  Future<void> _onLogout(LogoutEvent event, Emitter<LoginState> emit) async {
    await _auth.signOut();
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    await _sessionService.clearSession();
    emit(LoginInitial());
  }

  Future<void> _onLoginSuccess() async {
    final sessionService = SessionService();
    await sessionService.setLoggedIn(true);
  }
}
