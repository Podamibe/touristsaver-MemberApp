import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../app_variables.dart';

class CongratsScreen extends StatefulWidget {
  static const String routeName = '/congrats-screen';
  final String piiinkCredit;

  const CongratsScreen({super.key, required this.piiinkCredit});

  @override
  State<CongratsScreen> createState() => _CongratsScreenState();
}

class _CongratsScreenState extends State<CongratsScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  double get _creditAmount =>
      double.tryParse(widget.piiinkCredit.replaceAll(',', '').trim()) ?? 0;

  String get _formattedCredits =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2)
          .format(_creditAmount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _activationHeaderImage(),
                SizedBox(height: 18.h),
                _successCard(),
                SizedBox(height: 22.h),
                _startExploringButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activationHeaderImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Image.asset(
            'assets/images/onboarding/header_activation.webp',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  Widget _successCard() {
    final bool hasCredits = _creditAmount > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 26.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111C44).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your membership is active',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: _headingColor,
              fontSize: 26.sp,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Welcome to TouristSaver. You can now explore nearby experiences, dining, attractions and travel savings across Australia & New Zealand.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: _bodyColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          if (hasCredits) ...[
            SizedBox(height: 22.h),
            _creditsCard(),
          ],
        ],
      ),
    );
  }

  Widget _creditsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FF),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFDCEBFF)),
      ),
      child: Column(
        children: [
          Text(
            'You’ve unlocked $_formattedCredits of TouristSaver Discount Credits',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: _headingColor,
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Use these Discount Credits toward eligible discounts and savings across participating merchants.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: _bodyColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Discount Credits are a membership benefit for accessing offers. They are not cash and cannot be withdrawn.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: _bodyColor,
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _startExploringButton() {
    return Container(
      height: 56.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryBlue, _ctaCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () {
            AppVariables.initNotifications = true;
            context.pushReplacementNamed(
              'bottom-bar',
              pathParameters: {'page': '3'},
            );
          },
          child: Center(
            child: Text(
              'Start exploring',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
