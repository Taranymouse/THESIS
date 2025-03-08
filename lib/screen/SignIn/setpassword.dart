import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';

class SetPasswordScreen extends StatefulWidget {
  final String email; // รับอีเมลจาก state ก่อนหน้านี้

  const SetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set New Password"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // ✅ กลับไปหน้า Login
        ),
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // ตั้งรหัสผ่านสำเร็จ -> ไปหน้า Home
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is LoginFailure) {
            // แสดง error message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "New Password"),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return "Password must be at least 8 characters long";
                    }
                    if (!RegExp(r"[0-9]").hasMatch(value)) {
                      return "Password must include at least one digit";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Call API to set new password
                      context.read<LoginBloc>().add(
                        SetNewPasswordEvent(
                          widget.email,
                          _newPasswordController.text,
                        ),
                      );
                    }
                  },
                  child: const Text("Set Password"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
