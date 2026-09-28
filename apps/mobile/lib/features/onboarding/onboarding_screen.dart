import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/auth_state.dart';
import '../home/home_shell.dart';

class _OnboardingStep {
  const _OnboardingStep({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}

const _steps = [
  _OnboardingStep(
    icon: Icons.chat_bubble_outline,
    title: 'Chat with Aura',
    body: 'Ask questions, get grounded answers with sources, across 6+ AI providers.',
  ),
  _OnboardingStep(
    icon: Icons.travel_explore,
    title: 'Deep research',
    body: 'Aura plans, searches, reads, and writes a full report — with citations.',
  ),
  _OnboardingStep(
    icon: Icons.mic_none,
    title: 'Voice-controlled',
    body: 'Talk to Aura online or fully offline, on any device.',
  ),
  _OnboardingStep(
    icon: Icons.task_alt,
    title: 'Tasks that run themselves',
    body: 'Hand off multi-step work and review it when it is done.',
  ),
];

/// A 4-step swipeable intro, ending in [HomeShell] once the user finishes
/// or skips.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(authControllerProvider.notifier).completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final step = _steps[i];
                  return Padding(
                    padding: const EdgeInsets.all(AuraSpace.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(step.icon, size: 64, color: AuraColors.violet),
                        const SizedBox(height: AuraSpace.lg),
                        Text(step.title, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: AuraSpace.sm),
                        Text(
                          step.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.aura.text2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: AuraMotion.ui,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AuraColors.violet : context.aura.border,
                    borderRadius: BorderRadius.circular(AuraRadius.pill),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AuraSpace.lg),
              child: FilledButton(
                onPressed: isLast
                    ? _finish
                    : () => _controller.nextPage(duration: AuraMotion.panel, curve: AuraMotion.standard),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AuraSpace.xs),
                  child: Text(isLast ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
