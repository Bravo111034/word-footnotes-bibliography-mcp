import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

const _planSteps = ['Gather source data', 'Draft outline', 'Write sections', 'Review & polish', 'Publish'];

/// Task Detail: objective, a plan timeline (done / current / pending), and
/// Pause/Stop controls (spec §28).
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.title, this.currentStepIndex = 2});

  final String title;
  final int currentStepIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AuraSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Objective', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AuraSpace.xxs),
            Text(title, style: TextStyle(color: context.aura.text2)),
            const SizedBox(height: AuraSpace.xl),
            Text('Plan', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AuraSpace.sm),
            Expanded(
              child: ListView.builder(
                itemCount: _planSteps.length,
                itemBuilder: (context, i) {
                  final isDone = i < currentStepIndex;
                  final isCurrent = i == currentStepIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AuraSpace.sm),
                    child: Row(
                      children: [
                        Icon(
                          isDone ? Icons.check_circle : (isCurrent ? Icons.radio_button_checked : Icons.circle_outlined),
                          size: 18,
                          color: isDone ? AuraColors.success : (isCurrent ? AuraColors.violet : context.aura.muted),
                        ),
                        const SizedBox(width: AuraSpace.sm),
                        Text(
                          _planSteps[i],
                          style: TextStyle(fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.pause), label: const Text('Pause')),
                ),
                const SizedBox(width: AuraSpace.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmStop(context),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmStop(BuildContext context) async {
    final confirmed = await AuraPermissionDialog.confirm(
      context,
      title: 'Stop this task?',
      description: 'Aura will stop working on "$title". Progress so far is kept, but the remaining steps will not run.',
      confirmLabel: 'Stop task',
      destructive: true,
    );
    if (confirmed && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
