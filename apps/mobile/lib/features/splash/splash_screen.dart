import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/auth_state.dart';
import '../auth/sign_in_screen.dart';
import '../home/home_shell.dart';
import '../onboarding/onboarding_screen.dart';

/// Shows the animated Aura orb while [authControllerProvider] restores the
/// persisted session, then routes to Sign In, Onboarding, or Home.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.isLoading) return;

      final Widget destination;
      if (!next.isSignedIn) {
        destination = const SignInScreen();
      } else if (!next.hasCompletedOnboarding) {
        destination = const OnboardingScreen();
      } else {
        destination = const HomeShell();
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => destination));
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuraIntelligenceIndicator(state: AuraState.thinking, size: 72),
            SizedBox(height: AuraSpace.lg),
            AuraGradientText('Aura', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
