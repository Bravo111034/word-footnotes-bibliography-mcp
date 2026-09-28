import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AuraDesktopApp());
}

class AuraDesktopApp extends StatelessWidget {
  const AuraDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura AI — Desktop',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.light,
      darkTheme: AuraTheme.dark,
      themeMode: ThemeMode.system,
      home: const DesktopShell(),
    );
  }
}

const _navItems = [
  AuraSidebarItem(icon: Icons.home_outlined, label: 'Home'),
  AuraSidebarItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
  AuraSidebarItem(icon: Icons.travel_explore, label: 'Research'),
  AuraSidebarItem(icon: Icons.folder_outlined, label: 'Projects'),
  AuraSidebarItem(icon: Icons.auto_awesome_outlined, label: 'Create'),
];

/// The 3-region desktop layout: fixed sidebar, main workspace, and a
/// collapsible context panel (spec §6). The workspace and context panel
/// content are placeholders until Chat/Research land in a later phase.
class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _selected = 0;
  bool _contextPanelOpen = true;

  @override
  Widget build(BuildContext context) {
    final aura = context.aura;

    return Scaffold(
      body: Row(
        children: [
          AuraSidebar(
            items: _navItems,
            selectedIndex: _selected,
            onSelect: (i) => setState(() => _selected = i),
            storageUsedLabel: '2.1 GB of 10 GB used',
          ),
          Expanded(
            child: Column(
              children: [
                AuraTopBar(
                  title: _navItems[_selected].label,
                  onSearchTap: () {},
                  onNotificationsTap: () {},
                  onProfileTap: () => setState(() => _contextPanelOpen = !_contextPanelOpen),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AuraIntelligenceIndicator(state: AuraState.idle, size: 48),
                        const SizedBox(height: AuraSpace.md),
                        Text('${_navItems[_selected].label} workspace', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_contextPanelOpen)
            Container(
              width: 320,
              decoration: BoxDecoration(border: Border(left: BorderSide(color: aura.border))),
              padding: const EdgeInsets.all(AuraSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Context', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AuraSpace.sm),
                  Text('No project selected.', style: TextStyle(color: aura.text2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
