import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';

class Login extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
            // context.read<LoginBloc>().emit(LoginInitial());
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // context.read<LoginBloc>().emit(LoginInitial());
          }
        },
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "IT/CS THESIS",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                          style: TextStyle(color: Colors.white, fontSize: 14),
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
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),

                // แสดง Loading ระหว่าง Login
                if (state is LoginLoading)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
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
