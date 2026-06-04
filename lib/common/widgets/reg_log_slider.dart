import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/generated/l10n.dart';

class RegLogSlider extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback? onregister;
  final VoidCallback? onLogin;
  final String? image;

  const RegLogSlider({
    super.key,
    this.title = "",
    this.body = "",
    this.onregister,
    this.onLogin,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill,
      child: Container(
        width: MediaQuery.of(context).size.width / 1,
        margin: const EdgeInsets.only(bottom: 80.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          children: [
            SizedBox(height: 15.h),

            // Grey Line
            Container(
              width: 65.w,
              height: 4.h,
              decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(50)),
            ),

            SizedBox(height: 15.h),

            // title Text
            AutoSizeText(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  decoration: TextDecoration.none,
                  color: Colors.black.withValues(alpha: 0.8),
                  fontFamily: 'Sans'),
            ),

            SizedBox(height: 15.h),

            // Body Text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: AutoSizeText(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    color: Colors.black.withValues(alpha: 0.5),
                    fontFamily: 'Sans'),
              ),
            ),

            SizedBox(height: 30.h),

            // Image
            SizedBox(
              // color: Colors.orange,
              child: Image.asset(
                image ?? 'assets/images/member-card.png',
                height: 150.h,
                width: MediaQuery.of(context).size.width / 2,
                fit: BoxFit.contain,
                // color: GlobalColors.appColor,
              ),
            ),

            SizedBox(height: 25.h),

            // Register Button
            ModalCustomButton(
              text: S.of(context).registerNow,
              onPressed: onregister,
            ),

            SizedBox(height: 15.h),

            // Login Button
            ModalCustomButton1(
              text: S.of(context).logIn,
              onPressed: onLogin,
            ),

            SizedBox(height: 15.h),
          ],
        ),
      ),
    );
  }
}
