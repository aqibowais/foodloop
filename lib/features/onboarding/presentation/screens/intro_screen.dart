import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/page_transitions.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/signup_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Turn surplus into smiles',
      description:
          'List extra meals in minutes so nearby families and NGOs can find them before they go to waste.',
      badge: 'Climate action • SDG 13',
    ),
    _OnboardingPageData(
      title: 'Connect donors & receivers',
      description:
          'Households, restaurants and event hosts share food. Anyone in need can safely request and pick it up.',
      badge: 'Donors • Receivers • NGOs',
    ),
    _OnboardingPageData(
      title: 'See your real impact',
      description:
          'Track meals shared, reduce landfill food waste and build a culture of sharing in your city.',
      badge: 'Meals shared • Waste avoided',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToSignUp();
    }
  }

  void _skip() {
    _goToLogin();
  }

  void _goToSignUp() {
    Navigator.push(context, FadePageRoute(child: const SignUpScreen()));
  }

  void _goToLogin() {
    Navigator.push(context, FadePageRoute(child: const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Top brand row
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        height: 36,
                        width: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'FoodLoop',
                      style: AppTypography.h3(color: AppColors.pureWhite),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Onboarding pages with subtle slide/scale animation
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];

                      final pagePosition = _pageController.hasClients
                          ? _pageController.page ?? _currentPage.toDouble()
                          : _currentPage.toDouble();
                      final distance = (pagePosition - index).abs().clamp(
                        0.0,
                        1.0,
                      );

                      // 1.0 when centered, a bit smaller/faded when swiping away
                      final scale = 1.0 - (0.08 * distance);
                      final opacity = 1.0 - (0.3 * distance);
                      final offsetY = 16.0 * distance;

                      return Transform.translate(
                        offset: Offset(0, offsetY),
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.asset(
                                    'assets/icons/app_icon.png',
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.h1(
                                    color: AppColors.pureWhite,
                                    fontSize: 26,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body(
                                    color: AppColors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardDark.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.accentGreenSoft,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.eco_outlined,
                                        color: AppColors.accentGreen,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        page.badge,
                                        style: AppTypography.caption(
                                          color: AppColors.pureWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(flex: 2),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isActive ? 22 : 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accentGreen
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Bottom buttons
                Row(
                  children: [
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: AppTypography.bodySmall(color: AppColors.grey),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: AppColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          elevation: 0,
                        ),
                        onPressed: _goNext,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get started'
                                  : 'Next',
                              style: AppTypography.button(
                                color: AppColors.black,
                              ).copyWith(fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Auth shortcuts
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New here? ',
                      style: AppTypography.bodySmall(color: AppColors.grey),
                    ),
                    GestureDetector(
                      onTap: _goToSignUp,
                      child: Text(
                        'Create account',
                        style: AppTypography.bodySmall(
                          color: AppColors.accentGreen,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already using FoodLoop? ',
                      style: AppTypography.bodySmall(color: AppColors.grey),
                    ),
                    GestureDetector(
                      onTap: _goToLogin,
                      child: Text(
                        'Sign in',
                        style: AppTypography.bodySmall(
                          color: AppColors.accentGreen,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String badge;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.badge,
  });
}
