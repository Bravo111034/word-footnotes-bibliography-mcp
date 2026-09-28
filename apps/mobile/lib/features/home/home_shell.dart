import 'package:flutter/material.dart';

import '../create/create_studio_screen.dart';
import '../projects/projects_screen.dart';
import '../tasks/task_center_screen.dart';
import 'home_screen.dart';

/// Bottom-nav shell tying Home, Create, Tasks, and Projects together so
/// Phase 4's screens are reachable. The full mobile chrome pass (motion,
/// sheets, a "More" overflow) is Phase 5 — this is the minimum to navigate.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CreateStudioScreen(),
    TaskCenterScreen(),
    ProjectsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Projects'),
        ],
      ),
    );
  }
}
