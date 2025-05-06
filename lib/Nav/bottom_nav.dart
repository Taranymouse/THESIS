import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/bloc/BottomNav/bottom_nav_bloc.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        int currentIndex = (state is CurrentPage) ? state.currentIndex : 1;
        return ConvexAppBar(
          backgroundColor: ColorPlate.colors[6].color,
          color: Colors.black,
          activeColor: ColorPlate.colors[5].color,
          style: TabStyle.react,
          items: const [
            TabItem(icon: Icons.notifications_rounded, title: 'แจ้งเตือน'),
            TabItem(icon: Icons.home, title: 'หน้าแรก'),
            TabItem(icon: Icons.settings, title: 'ตั้งค่า'),
          ],
          initialActiveIndex: currentIndex,
          onTap: (index) {
            context.read<BottomNavBloc>().add(ChangePage(index: index));
          },
        );
      },
    );
  }
}
