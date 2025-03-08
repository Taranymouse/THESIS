import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/Login/login_bloc.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginInitial) {
          // ถ้า state เป็น LoginInitial ให้กลับไปหน้า Login
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text("Settings")),
          body: Column(
            children: [
              if (state is LoginLoading) // ถ้ากำลัง Logout ให้แสดง Loading
                Center(child: CircularProgressIndicator()),
              ListTile(
                title: Text("Logout"),
                trailing: Icon(Icons.exit_to_app),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Logout',
      desc: 'ต้องการที่จะออกจากระบบหรือไม่?',
      btnOkOnPress: () {
        context.read<LoginBloc>().add(LogoutEvent());
      },
      btnCancelOnPress: () {},
    ).show();
  }
}
