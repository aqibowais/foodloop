import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/onboarding/presentation/screens/intro_screen.dart';

/// Decides whether to show auth flow or main app based on Firebase auth state.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const OnboardingScreen();
        }
        return const _MainShell();
      },
      loading: () => const _SplashFallback(),
      error: (_, __) => const OnboardingScreen(),
    );
  }
}

/// Simple dark fallback while checking auth.
class _SplashFallback extends StatelessWidget {
  const _SplashFallback();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Placeholder main shell for the authenticated part of FoodLoop.
/// We'll replace this with the real Home / Orders / Profile tabs later.
class _MainShell extends StatelessWidget {
  const _MainShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: const Center(
          child: Text(
            'FoodLoop Home (placeholder)',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
