import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/services/onboarding_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/onboarding/presentation/screens/intro_screen.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';
import 'features/user/providers/user_provider.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';

/// Decides whether to show auth flow or main app based on Firebase auth state.
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isCheckingOnboarding = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final completed = await OnboardingService.isOnboardingCompleted();
    if (mounted) {
      setState(() {
        _onboardingCompleted = completed;
        _isCheckingOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingOnboarding) {
      return const _SplashFallback();
    }

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // If onboarding completed, show login screen, otherwise show onboarding
          return _onboardingCompleted
              ? const LoginScreen()
              : const OnboardingScreen();
        }
        // Check if user is admin and navigate to dashboard
        return const _MainShell();
      },
      loading: () => const _SplashFallback(),
      error: (_, __) {
        // On error, check onboarding status
        return _onboardingCompleted
            ? const LoginScreen()
            : const OnboardingScreen();
      },
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

/// Main shell for the authenticated part of FoodLoop.
class _MainShell extends ConsumerWidget {
  const _MainShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.user;
    
    // If user is admin, show admin dashboard
    if (user != null && user.isAdmin) {
      return const AdminDashboardScreen();
    }
    
    // Otherwise show regular home screen with navigation
    return const MainNavigationScreen();
  }
}
