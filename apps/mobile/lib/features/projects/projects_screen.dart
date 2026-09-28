import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import 'project_workspace_screen.dart';

class _Project {
  const _Project({required this.name, required this.description, required this.lastActivity, required this.activeTasks});

  final String name;
  final String description;
  final String lastActivity;
  final int activeTasks;
}

const _projects = [
  _Project(name: 'EV Battery Market', description: 'Deep research + quarterly brief', lastActivity: '2h ago', activeTasks: 1),
  _Project(name: 'Brand Refresh', description: 'Moodboards, copy, and social assets', lastActivity: 'Yesterday', activeTasks: 0),
  _Project(name: 'Customer Interviews', description: 'Synthesis of 12 interviews', lastActivity: '3 days ago', activeTasks: 2),
];

/// Projects landing: cards with name, description, last activity, and
/// active-task count (spec §21).
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AuraSpace.md),
        itemCount: _projects.length,
        separatorBuilder: (_, __) => const SizedBox(height: AuraSpace.sm),
        itemBuilder: (context, i) {
          final project = _projects[i];
          return AuraCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProjectWorkspaceScreen(projectName: project.name)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(project.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                    if (project.activeTasks > 0)
                      AuraStatusBadge(label: '${project.activeTasks} ACTIVE', tone: AuraBadgeTone.violet),
                  ],
                ),
                const SizedBox(height: AuraSpace.xxs),
                Text(project.description, style: TextStyle(color: context.aura.text2)),
                const SizedBox(height: AuraSpace.sm),
                Text('Last activity: ${project.lastActivity}', style: TextStyle(fontSize: 12, color: context.aura.muted)),
              ],
            ),
          );
        },
      ),
    );
  }
}
