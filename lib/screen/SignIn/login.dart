import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/SignIn/set_password_screen.dart';

class Login extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state is LoginSuccess) {
            // 👉 บันทึกว่าผู้ใช้เข้าสู่ระบบแล้ว
            SessionService().setLoggedIn(true);

            // 👉 บันทึก Role ของผู้ใช้งาน
            await SessionService().saveUserRole(state.role);
            print("บันทึก Role สำเร็จ : ${state.role}");

            context.read<BottomNavBloc>().add(ChangePage(index: 1));
            // ตรวจสอบ role และไปยังหน้าแตกต่างกันตาม role
            if (state.role == "1") {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state.role == "2") {
              Navigator.pushReplacementNamed(context, '/prof-home');
            } else if (state.role == "4") {
              Navigator.pushReplacementNamed(context, '/admin-home');
            } else {
              // ในกรณีที่ role ไม่ตรงกับที่กำหนด
              print("Role not recognized: $state.role");
            }
          } else if (state is RequireSetPasswordState) {
            Navigator.pushReplacementNamed(
              context,
              '/set-password',
              arguments: {
                'email': state.email,
                'displayName': state.displayName,
              },
            );
          } else if (state is LoginRequireSetPassword) {
            Navigator.pushReplacementNamed(
              context,
              '/set-password',
              arguments: state.email,
            );
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // พิมพ์ Error ลงใน Terminal
            print("Login Error: ${state.message}");
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              AbsorbPointer(
                // ป้องกันการกดปุ่มซ้ำ
                absorbing: state is LoginLoading,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "IT/CS PROJECTS",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(_emailController, "Email", Icons.email),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _passwordController,
                        "Password",
                        Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),

                      // ปุ่ม Login
                      Material(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(25),
                        child: InkWell(
                          onTap: () {
                            if (_emailController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("กรุณากรอกข้อมูลให้ครบ"),
                                ),
                              );
                              return;
                            }
                            context.read<LoginBloc>().add(
                              LoginWithEmailPassword(
                                _emailController.text,
                                _passwordController.text,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ปุ่ม Sign in with Google
                      Material(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(25),
                        child: InkWell(
                          onTap: () {
                            context.read<LoginBloc>().add(LoginWithGoogle());
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Center(
                              child: Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay Loading (เมื่อ state เป็น LoginLoading)
              if (state is LoginLoading)
                Container(
                  color: Colors.black.withOpacity(0.5), // พื้นหลังสีดำโปร่งแสง
                  child: Center(
                    child: LoadingAnimationWidget.flickr(
                      leftDotColor: Colors.deepPurple,
                      rightDotColor: Colors.orange,
                      size: 100,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // TextField
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: obscureText,
    );
  }
}
