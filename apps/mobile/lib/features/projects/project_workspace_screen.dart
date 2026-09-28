import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';
import '../memory/memory_manager_screen.dart';
import '../research/research_home_screen.dart';
import '../tasks/task_center_screen.dart';

const _tabs = ['Overview', 'Chat', 'Research', 'Files', 'Notes', 'Tasks', 'Memory', 'Published'];

/// Project Workspace: tabbed layout over one project's brief, activity, and
/// tools (spec §22). Tabs that already have a full screen (Chat, Research,
/// Tasks, Memory) embed it directly; the rest are placeholders.
class ProjectWorkspaceScreen extends StatelessWidget {
  const ProjectWorkspaceScreen({super.key, required this.projectName});

  final String projectName;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(projectName),
          bottom: TabBar(isScrollable: true, tabs: _tabs.map((t) => Tab(text: t)).toList()),
        ),
        body: TabBarView(
          children: _tabs.map((tab) {
            switch (tab) {
              case 'Chat':
                return const ChatScreen();
              case 'Research':
                return const ResearchHomeScreen();
              case 'Tasks':
                return const TaskCenterScreen();
              case 'Memory':
                return const MemoryManagerScreen();
              default:
                return Center(
                  child: Text('$tab — coming soon', style: TextStyle(color: context.aura.text2)),
                );
            }
          }).toList(),
        ),
      ),
    );
  }
}
