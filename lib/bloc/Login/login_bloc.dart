import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      emit(LoginSuccess(email, displayName)); // 🌟 เพิ่ม Display Name
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

      await _sessionService.saveUserSession(user.email!);
      emit(LoginSuccess(user.email!, displayName)); // 🌟 ส่ง Display Name กลับไป
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

      final signInMethods = await _auth.fetchSignInMethodsForEmail(user.email!);

      if (signInMethods.contains('password')) {
        emit(
          const LoginFailure(
            "This email is already registered with email/password.",
          ),
        );
        return;
      }

      await _sessionService.saveUserSession(user.email!);
      emit(LoginSuccess(user.email!, displayName)); // 🌟 ส่ง Display Name กลับไป
    } catch (e) {
      emit(LoginFailure("Google Sign-In Failed: ${e.toString()}"));
    }
  }

  // 🚪 ---- 4. Logout ----
  Future<void> _onLogout(LogoutEvent event, Emitter<LoginState> emit) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _sessionService.clearUserSession();
    emit(LoginInitial());
  }
}
