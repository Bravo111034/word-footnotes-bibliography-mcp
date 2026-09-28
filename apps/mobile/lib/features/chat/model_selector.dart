import 'package:aura_ai_gateway/aura_ai_gateway.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/chat_state.dart';

/// The Auto / Fast / Balanced / Deep / Research / Creative / Custom picker
/// (spec §15), shown as a menu button with a provider-status pill.
class ModelSelector extends ConsumerWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(aiModeProvider);
    final provider = ref.watch(activeProviderProvider);
    final gateway = ref.watch(aiGatewayProvider);
    final available = gateway.isAvailable(provider);

    return PopupMenuButton<AiMode>(
      initialValue: mode,
      onSelected: (m) => ref.read(aiModeProvider.notifier).state = m,
      itemBuilder: (context) => AiMode.values
          .map((m) => PopupMenuItem(value: m, child: Text(m.displayName)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AuraSpace.sm, vertical: AuraSpace.xxs),
        decoration: BoxDecoration(
          border: Border.all(color: context.aura.border),
          borderRadius: BorderRadius.circular(AuraRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: available ? AuraColors.success : AuraColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AuraSpace.xxs),
            Text('${mode.displayName} · ${provider.displayName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const Icon(Icons.expand_more, size: 16),
          ],
        ),
      ),
    );
  }
}
