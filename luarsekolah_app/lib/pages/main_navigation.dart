// lib/pages/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../pages/home_page.dart';
import '../features/course/presentation/pages/course_list_page.dart';
import '../features/course/presentation/bindings/course_binding.dart';
import '../features/todo/presentation/pages/todo_list_page.dart';
import '../features/todo/presentation/bindings/todo_binding.dart';
import '../pages/account_menu_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final Color primaryColor = const Color(0xFF0EA781);
  final Color inactiveColor = const Color(0xFF6C6F70);

  @override
  void initState() {
    super.initState();
    // Inject bindings for Course and Todo features
    CourseBinding().dependencies();
    TodoBinding().dependencies();
  }

  final _pages = const [
    HomePage(),
    CourseListPage(),
    TodoListPage(),
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
      icon: Icon(Icons.task_outlined),
      selectedIcon: Icon(Icons.task),
      label: 'ToDo',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Akun Saya',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.white,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withOpacity(0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? primaryColor
                  : inactiveColor)),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
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
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: _destinations,
          animationDuration: const Duration(milliseconds: 400),
        ),
      ),
    );
  }
}