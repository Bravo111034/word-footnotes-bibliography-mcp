import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether a session is signed in, and whether persisted state has finished
/// loading yet (so Splash knows when it's safe to route).
class AuthState {
  const AuthState({required this.isSignedIn, required this.isLoading, this.hasCompletedOnboarding = false});

  final bool isSignedIn;
  final bool isLoading;
  final bool hasCompletedOnboarding;

  AuthState copyWith({bool? isSignedIn, bool? isLoading, bool? hasCompletedOnboarding}) {
    return AuthState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isLoading: isLoading ?? this.isLoading,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  static const initial = AuthState(isSignedIn: false, isLoading: true);
}

const _signedInKey = 'aura.auth.signedIn';
const _onboardedKey = 'aura.auth.onboarded';

/// Session auth state, persisted locally via [SharedPreferences].
///
/// This is a scaffold: it persists a signed-in flag so navigation and UI can
/// be built end-to-end, but does not talk to Supabase yet — real
/// email/Google auth lands when the backend is wired up.
class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState.initial) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = AuthState(
      isSignedIn: prefs.getBool(_signedInKey) ?? false,
      isLoading: false,
      hasCompletedOnboarding: prefs.getBool(_onboardedKey) ?? false,
    );
  }

  Future<void> signIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, true);
    state = state.copyWith(isSignedIn: true);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, false);
    state = state.copyWith(isSignedIn: false);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, true);
    state = state.copyWith(hasCompletedOnboarding: true);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
