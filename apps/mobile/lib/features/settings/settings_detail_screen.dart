import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

/// A generic placeholder for a Settings category whose controls haven't
/// been built yet.
class SettingsDetailScreen extends StatelessWidget {
  const SettingsDetailScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Center(
        child: Text('$category settings — coming soon', style: TextStyle(color: context.aura.text2)),
      ),
    );
  }
}
