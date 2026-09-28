import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import 'features/catalog/widget_catalog_screen.dart';

void main() {
  runApp(const AuraApp());
}

/// Root of the Aura mobile app. For P0 this boots straight into the widget
/// catalog so every new token/primitive can be QA'd as it lands; later
/// phases replace [home] with the real navigation shell.
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
      home: const WidgetCatalogScreen(),
    );
  }
}
