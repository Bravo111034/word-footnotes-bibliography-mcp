import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import 'task_detail_screen.dart';

class _Task {
  const _Task({required this.title, required this.progress});

  final String title;
  final double progress;
}

const _tabs = ['Active', 'Scheduled', 'Awaiting Approval', 'Completed', 'Failed'];

const _tasksByTab = <String, List<_Task>>{
  'Active': [
    _Task(title: 'Publishing weekly newsletter', progress: 0.6),
    _Task(title: 'Comparing 3 vendor proposals', progress: 0.3),
  ],
  'Scheduled': [_Task(title: 'Monday competitor digest', progress: 0)],
  'Awaiting Approval': [_Task(title: 'LinkedIn post: Q3 recap', progress: 1)],
  'Completed': [_Task(title: 'Weekly report', progress: 1)],
  'Failed': [_Task(title: 'Publish to X — auth expired', progress: 1)],
};

/// Task Center: Active / Scheduled / Awaiting Approval / Completed / Failed
/// tabs with real-time progress rows (spec §27).
class TaskCenterScreen extends StatelessWidget {
  const TaskCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          bottom: TabBar(isScrollable: true, tabs: _tabs.map((t) => Tab(text: t)).toList()),
        ),
        body: TabBarView(
          children: _tabs.map((tab) {
            final tasks = _tasksByTab[tab] ?? const [];
            if (tasks.isEmpty) {
              return Center(child: Text('No $tab tasks', style: TextStyle(color: context.aura.text2)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AuraSpace.md),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: AuraSpace.sm),
              itemBuilder: (context, i) {
                final task = tasks[i];
                return AuraCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TaskDetailScreen(title: task.title)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AuraSpace.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AuraRadius.pill),
                        child: LinearProgressIndicator(value: task.progress, minHeight: 4),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
