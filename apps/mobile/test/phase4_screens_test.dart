import 'package:aura_mobile/features/create/create_studio_screen.dart';
import 'package:aura_mobile/features/home/home_shell.dart';
import 'package:aura_mobile/features/memory/memory_manager_screen.dart';
import 'package:aura_mobile/features/projects/project_workspace_screen.dart';
import 'package:aura_mobile/features/projects/projects_screen.dart';
import 'package:aura_mobile/features/tasks/task_center_screen.dart';
import 'package:aura_mobile/features/tasks/task_detail_screen.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return ProviderScope(child: MaterialApp(theme: AuraTheme.light, home: child));
}

void main() {
  testWidgets('HomeShell switches between its bottom-nav destinations', (tester) async {
    await tester.pumpWidget(_wrap(const HomeShell()));
    await tester.pump();

    expect(find.text('Good to see you.'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pump();
    expect(find.text('EV battery report.pdf'), findsOneWidget);
  });

  testWidgets('ProjectsScreen opens a ProjectWorkspaceScreen', (tester) async {
    await tester.pumpWidget(_wrap(const ProjectsScreen()));
    await tester.pump();

    await tester.tap(find.text('EV Battery Market'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectWorkspaceScreen), findsOneWidget);
    expect(find.text('Overview'), findsWidgets);
  });

  testWidgets('TaskCenterScreen opens a TaskDetailScreen', (tester) async {
    await tester.pumpWidget(_wrap(const TaskCenterScreen()));
    await tester.pump();

    await tester.tap(find.text('Publishing weekly newsletter'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
  });

  testWidgets('MemoryManagerScreen renders its sections', (tester) async {
    await tester.pumpWidget(_wrap(const MemoryManagerScreen()));
    await tester.pump();

    expect(find.text('Saved Knowledge'), findsOneWidget);
  });

  testWidgets('CreateStudioScreen renders its category grid', (tester) async {
    await tester.pumpWidget(_wrap(const CreateStudioScreen()));
    await tester.pump();

    expect(find.text('Image'), findsOneWidget);

    // The grid is lazily built, so a category near the end ("Diagram")
    // isn't in the tree until it's scrolled into view.
    await tester.dragUntilVisible(
      find.text('Diagram'),
      find.byType(GridView),
      const Offset(0, -200),
    );
    expect(find.text('Diagram'), findsOneWidget);
  });
}
