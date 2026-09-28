import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

const _steps = ['Content', 'Destinations', 'Adapt', 'Preview', 'Approval', 'Publish', 'Verify'];

/// The publishing workflow (spec §37): Content -> Destinations -> Adapt ->
/// Preview -> Approval -> Publish -> Verify, as a linear stepper. Approval
/// is gated behind [AuraPermissionDialog] since it's the point where
/// content becomes public. Returns true if the flow was completed.
class PublishingWorkflowDrawer extends StatefulWidget {
  const PublishingWorkflowDrawer({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PublishingWorkflowDrawer(),
    );
    return result ?? false;
  }

  @override
  State<PublishingWorkflowDrawer> createState() => _PublishingWorkflowDrawerState();
}

class _PublishingWorkflowDrawerState extends State<PublishingWorkflowDrawer> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Stepper(
          type: StepperType.vertical,
          currentStep: _step,
          controlsBuilder: (context, details) => Padding(
            padding: const EdgeInsets.only(top: AuraSpace.sm),
            child: Row(
              children: [
                if (_step > 0)
                  TextButton(onPressed: () => setState(() => _step -= 1), child: const Text('Back')),
                const Spacer(),
                FilledButton(
                  onPressed: () => _advance(context),
                  child: Text(_step == _steps.length - 1 ? 'Done' : (_step == 4 ? 'Approve' : 'Next')),
                ),
              ],
            ),
          ),
          steps: [
            for (var i = 0; i < _steps.length; i++)
              Step(
                title: Text(_steps[i]),
                isActive: i <= _step,
                state: i < _step ? StepState.complete : StepState.indexed,
                content: _StepBody(step: _steps[i]),
              ),
          ],
        );
      },
    );
  }

  Future<void> _advance(BuildContext context) async {
    if (_step == 4) {
      final approved = await AuraPermissionDialog.confirm(
        context,
        title: 'Approve for publishing?',
        description: 'This content will be published to its selected destinations once you continue.',
        confirmLabel: 'Approve',
      );
      if (!approved || !mounted) return;
    }

    if (_step == _steps.length - 1) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _step += 1);
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.step});

  final String step;

  @override
  Widget build(BuildContext context) {
    final description = switch (step) {
      'Content' => 'The draft text, image, or video to publish.',
      'Destinations' => 'Pick which platforms this goes to.',
      'Adapt' => 'Aura tailors format and length per destination.',
      'Preview' => 'Review exactly how it will look on each platform.',
      'Approval' => 'A human sign-off before anything goes public.',
      'Publish' => 'Aura sends it to each destination.',
      'Verify' => 'Confirms it actually went live.',
      _ => '',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpace.sm),
      child: Text(description, style: TextStyle(color: context.aura.text2)),
    );
  }
}
