import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/splash/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: AuraApp()));
}

/// Root of the Aura mobile app. Boots into [SplashScreen], which routes to
/// Sign In, Onboarding, or Home once the persisted session has loaded.
class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura AI',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.light,
      darkTheme: AuraTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
