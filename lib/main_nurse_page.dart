import 'package:flutter/material.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/home_nurse_page.dart';
import 'screens/profile_page.dart';
import 'screens/Notification_page.dart';

class MainNursePage extends StatefulWidget {
  const MainNursePage({super.key});

  @override
  State<MainNursePage> createState() => _MainPageState();
}

class _MainPageState extends State<MainNursePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeNursePage(),
    const NotificationPage(),
    const ProfileSettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
