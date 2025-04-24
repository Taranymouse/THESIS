import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SessionService _sessionService = SessionService();

  LoginBloc() : super(LoginInitial()) {
    on<LoginWithEmailPassword>(_onLoginWithEmailPassword);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<CheckSessionEvent>(_onCheckSession);
    on<LogoutEvent>(_onLogout);
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
      final token = await _sessionService.getAuthToken();
      final uid = await _sessionService.getUserUid();

      if (token == null || uid == null) {
        emit(const LoginFailure("Missing token or uid"));
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": event.email,
          "password": event.password,
          "uid": uid,
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final String? token = data["token"];

        if (token == null) {
          emit(const LoginFailure("Login failed: No token received"));
          return;
        }

        await _sessionService.saveAuthToken(token);

        // ดึงข้อมูลผู้ใช้
        final responseUser = await http.get(
          Uri.parse('$baseUrl/api/auth/user'),
          headers: {"Authorization": "Bearer $token"},
        );

        if (responseUser.statusCode == 200) {
          final dataUser = jsonDecode(utf8.decode(responseUser.bodyBytes));
          final String displayName = dataUser['display_name'] ?? 'No Name';
          final String email = dataUser['email'] ?? event.email;

          final String? role = dataUser['id_role']?.toString();
          final dynamic password = dataUser['password'];

          if (password == null) {
            emit(RequireSetPasswordState(email, displayName, role ?? ''));
          } else {
            emit(LoginSuccess(email, displayName, role ?? ''));
          }
        }
      } else {
        emit(LoginFailure("Login Failed: ${response.body}"));
      }
    } catch (e) {
      emit(LoginFailure("Login Failed: ${e.toString()}"));
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
      final String uid = user.uid;

      print("Google ID Token: $idToken");

      // 📌 เรียก API `/login`
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      print("Response Body : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final String? token = data["token"];

        if (token == null) {
          emit(const LoginFailure("Login failed: No token received"));
          return;
        }

        // 📌 บันทึกข้อมูลลงใน SessionService
        await _sessionService.saveAuthToken(token);
        await _sessionService.saveEmailSession(email);
        await _sessionService.saveDisplayName(displayName);
        await _sessionService.saveUserUid(uid);

        // 📌 เรียก API `/auth/user` เพื่อดึงข้อมูลผู้ใช้
        final responseUser = await http.get(
          Uri.parse('$baseUrl/api/auth/user'),
          headers: {"Authorization": "$token"},
        );

        if (responseUser.statusCode == 200) {
          final dataUser = jsonDecode(utf8.decode(responseUser.bodyBytes));
          final String? role = dataUser['id_role']?.toString();
          final dynamic password = dataUser['password'];

          // 📌 บันทึก role ลงใน SessionService
          await _sessionService.saveUserRole(role ?? 'No Role');
          print("!!## Role : $role");

          if (password == null) {
            // 🌟 ถ้า password ยังไม่เคยตั้ง
            emit(RequireSetPasswordState(email, displayName, role ?? ''));
          } else {
            emit(LoginSuccess(email, displayName, role ?? ''));
          }
        }
      } else {
        emit(LoginFailure("Login Failed: ${response.body}"));
      }
    } catch (e) {
      emit(LoginFailure("Google Sign-In Failed: ${e.toString()}"));
    }
  }

  // 🚪 ---- 4. Logout ----
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
