import 'package:flutter/material.dart';

import '../theme/aura_theme.dart';
import '../theme/aura_tokens.dart';
import 'aura_gradient_text.dart';

class AuraSidebarItem {
  const AuraSidebarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The desktop sidebar: brand mark, primary nav icons, and a footer with a
/// storage indicator and user avatar. Fixed 248px wide per the spec.
class AuraSidebar extends StatelessWidget {
  const AuraSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.storageUsedLabel,
  });

  static const double width = 248;

  final List<AuraSidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String? storageUsedLabel;

  @override
  Widget build(BuildContext context) {
    final aura = context.aura;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(right: BorderSide(color: aura.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AuraSpace.lg, AuraSpace.lg, AuraSpace.lg, AuraSpace.md),
            child: AuraGradientText(
              'Aura',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AuraSpace.sm),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: selected ? AuraColors.violet.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AuraRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AuraRadius.md),
                      onTap: () => onSelect(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AuraSpace.sm, vertical: AuraSpace.sm),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 18, color: selected ? AuraColors.violet : aura.text2),
                            const SizedBox(width: AuraSpace.sm),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: selected ? AuraColors.violet : null,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (storageUsedLabel != null)
            Padding(
              padding: const EdgeInsets.all(AuraSpace.md),
              child: Text(storageUsedLabel!, style: TextStyle(fontSize: 12, color: aura.text2)),
            ),
        ],
      ),
    );
  }
}
