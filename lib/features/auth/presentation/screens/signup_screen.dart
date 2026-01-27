import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../../core/utils/app_toast.dart';
import '../../providers/auth_provider.dart';
import '../../../../app.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.signUpWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      AppToast.success(context, 'Account created successfully');

      // Wait for auth state to update, then navigate to AuthWrapper
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Navigate to AuthWrapper which will handle routing based on auth state
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        FadePageRoute(child: const AuthWrapper()),
        (route) => false,
      );
    } else {
      final state = ref.read(authControllerProvider);
      AppToast.error(context, state.error ?? 'Sign up failed');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      AppToast.success(context, 'Signed in with Google');

      // Wait for auth state to update, then navigate to AuthWrapper
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Navigate to AuthWrapper which will handle routing based on auth state
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        FadePageRoute(child: const AuthWrapper()),
        (route) => false,
      );
    } else {
      final state = ref.read(authControllerProvider);
      AppToast.error(context, state.error ?? 'Google sign in failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/icons/app_icon2.png',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 40),
                Text(
                  'SIGN IN WITH',
                  style: AppTypography.caption(
                    color: Colors.white,
                    fontSize: 16,
                  ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 2),
                ).animate().fadeIn(delay: 200.ms).moveX(begin: -20),
                const SizedBox(height: 12),

                Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: authState.isLoading
                              ? null
                              : _handleGoogleSignIn,
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/google_icon.png',
                                height: 24,
                                width: 24,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sign in with Google',
                                style: AppTypography.button(
                                  color: Colors.white,
                                ).copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: Colors.white10),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTypography.caption(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: Colors.white10),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _emailController,
                  hint: 'Email Address',
                  icon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    if (!value.contains('@'))
                      return 'Please enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).moveY(begin: 10),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your password';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 600.ms).moveY(begin: 10),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_clock_outlined,
                  isPassword: true,
                  obscure: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please confirm your password';
                    if (value != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ).animate().fadeIn(delay: 700.ms).moveY(begin: 10),

                const SizedBox(height: 32),

                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: authState.isLoading ? null : _handleSignUp,
                      borderRadius: BorderRadius.circular(16),
                      child: authState.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Create account',
                                    style: AppTypography.button(
                                      color: AppColors.black,
                                    ).copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.black,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      text: "Already using FoodLoop? ",
                      style: AppTypography.bodySmall(color: Colors.white54),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        // All borders below are rounded and consistent; no extra parent container needed.
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.32),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.withOpacity(0.8), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}
