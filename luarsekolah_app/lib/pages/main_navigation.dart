import 'dart:ui';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/class_page.dart';
import '../pages/account_menu_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    ClassPage(),
    AccountMenuPage(),
  ];

  final _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.video_library_outlined),
      selectedIcon: Icon(Icons.video_library),
      label: 'Kelas',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Akun Saya',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0EA781);
    const inactiveColor = Color(0xFF6C6F70);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withOpacity(0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) =>
              IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? primaryColor
                      : inactiveColor)),
          labelTextStyle: WidgetStateProperty.resolveWith((states) =>
              TextStyle(
                  color: states.contains(WidgetState.selected)
                      ? primaryColor
                      : inactiveColor,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 13)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: _destinations,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
