import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';

class IntroScreen extends StatelessWidget {
  static const String routeName = '/intro-screen';
  const IntroScreen({super.key});

  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headlineColor = Color(0xFF101B4D);
  static const Color _softText = Color(0xFF65708D);

  Future<void> _markWelcomeSeen() async {
    await Pref().writeData(key: accept, value: 'true');
  }

  Future<void> _goToRegister(BuildContext context) async {
    await _markWelcomeSeen();
    if (!context.mounted) return;
    context.goNamed('register');
  }

  Future<void> _goToLogin(BuildContext context) async {
    await _markWelcomeSeen();
    if (!context.mounted) return;
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Save on the experiences you love',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _headlineColor,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.16,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Dining, travel, shopping & holiday fun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _softText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          'assets/images/onboarding/header_welcome_au.webp',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 34.h),
                    _PrimaryActionButton(
                      label: 'Join Now',
                      onPressed: () => _goToRegister(context),
                    ),
                    SizedBox(height: 14.h),
                    _SecondaryActionButton(
                      label: 'Log In',
                      onPressed: () => _goToLogin(context),
                    ),
                    SizedBox(height: 18.h),
                    TextButton.icon(
                      onPressed: () => context.pushNamed('video-screen'),
                      style: TextButton.styleFrom(
                        foregroundColor: _primaryBlue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      icon: Icon(
                        Icons.play_circle_outline,
                        color: _primaryBlue,
                        size: 22.sp,
                      ),
                      label: Text(
                        'Watch 1-minute intro',
                        style: TextStyle(
                          color: _primaryBlue,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [
            IntroScreen._primaryBlue,
            IntroScreen._ctaCyan,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: IntroScreen._primaryBlue.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: IntroScreen._primaryBlue,
          side: const BorderSide(color: IntroScreen._primaryBlue, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: IntroScreen._primaryBlue,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
