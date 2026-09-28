import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/auth_state.dart';
import '../onboarding/onboarding_screen.dart';

/// Sign in with email or Google. Scaffolded for P1: both paths call
/// [AuthController.signIn] directly rather than a real backend — Supabase
/// email + OAuth wiring is a follow-up once credentials are configured.
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuraSpace.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuraIntelligenceIndicator(state: AuraState.idle, size: 56),
              const SizedBox(height: AuraSpace.md),
              const AuraGradientText('Welcome to Aura', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: AuraSpace.xxs),
              Text(
                'Your AI research analyst — chat, research, and create, online or off.',
                style: TextStyle(color: context.aura.text2),
              ),
              const SizedBox(height: AuraSpace.xxl),
              const TextField(
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AuraSpace.sm),
              FilledButton(
                onPressed: () => _completeSignIn(context, ref),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: AuraSpace.xs),
                  child: Text('Continue with Email'),
                ),
              ),
              const SizedBox(height: AuraSpace.sm),
              OutlinedButton.icon(
                onPressed: () => _completeSignIn(context, ref),
                icon: const Icon(Icons.g_mobiledata),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: AuraSpace.xs),
                  child: Text('Continue with Google'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeSignIn(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signIn();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
  }
}
