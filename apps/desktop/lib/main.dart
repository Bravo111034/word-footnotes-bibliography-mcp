import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AuraDesktopApp());
}

/// Desktop shell placeholder for P0. The real 3-region layout (sidebar +
/// workspace + context panel) lands in P1.
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
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AuraIntelligenceIndicator(state: AuraState.idle, size: 64),
              SizedBox(height: AuraSpace.md),
              AuraGradientText('Aura AI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
