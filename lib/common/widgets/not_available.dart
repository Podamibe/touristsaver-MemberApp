import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class NotAvailable extends StatelessWidget {
  final String titleText;
  final String bodyText;
  final String image;
  final void Function()? onPressed;

  const NotAvailable({
    super.key,
    this.titleText = '',
    this.bodyText = '',
    this.image = "assets/images/coming-soon-icon.png",
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        margin: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(2, 2),
              )
            ]),
        child: Column(
          children: [
            AutoSizeText(
              titleText,
              style: topicStyle,
            ),

            const SizedBox(height: 15),

            // Body Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: AutoSizeText(
                bodyText,
                textAlign: TextAlign.center,
                style: textStyle15.copyWith(fontSize: 18.sp),
              ),
            ),

            const SizedBox(height: 50),

            // Image
            SizedBox(
              // color: Colors.orange,
              child: Image.asset(
                image,
                height: 130.h,
                width: MediaQuery.of(context).size.width / 2,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            // Ok Button
            CustomButton(
              text: S.of(context).ok,
              onPressed: onPressed ??
                  () {
                    context.pop();
                  },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class NoDataFound extends StatelessWidget {
  final String titleText;
  final String bodyText;
  final String image;

  const NoDataFound({
    super.key,
    this.titleText = '',
    this.bodyText = '',
    this.image = "assets/images/oops.png",
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        margin: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(2, 2),
              )
            ]),
        child: Column(
          children: [
            AutoSizeText(
              titleText,
              style: topicStyle,
            ),

            const SizedBox(height: 15),

            // Body Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: AutoSizeText(
                bodyText,
                textAlign: TextAlign.center,
                style: textStyle15.copyWith(fontSize: 18.sp),
              ),
            ),

            const SizedBox(height: 30),

            // Image
            SizedBox(
              // color: Colors.orange,
              child: Image.asset(
                image,
                height: 130.h,
                width: MediaQuery.of(context).size.width / 2,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
