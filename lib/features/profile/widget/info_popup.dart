import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class InfoPopUp extends StatelessWidget {
  final String title;
  final String body;
  final String footer;
  final VoidCallback? onOk;
  final TextAlign? textAlign;
  // final double height;
  final String image;
  const InfoPopUp({
    super.key,
    this.title = '',
    this.body = '',
    this.footer = '',
    this.onOk,
    // this.height = 500.0,
    this.image = "assets/images/shopping-bag.png",
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.vertical,
      onDismissed: (_) => Navigator.of(context).pop(),
      // key: const Key('key'),
      key: UniqueKey(),
      child: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          // height: height,
          width: MediaQuery.of(context).size.width / 1.1,
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 15),

              // Grey Line
              Container(
                width: 65,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50)),
              ),

              const SizedBox(height: 20),

              // title Text
              AutoSizeText(
                title,
                textAlign: textAlign,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    decoration: TextDecoration.none,
                    color: Colors.black.withValues(alpha: 0.8),
                    fontFamily: 'Sans'),
              ),

              const SizedBox(height: 15),

              // Body Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: AutoSizeText(
                  body,
                  textAlign: TextAlign.center,
                  style: transactionTextStyle.copyWith(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Image
              SizedBox(
                // color: Colors.orange,
                child: Image.asset(
                  image,
                  height: 160,
                  width: MediaQuery.of(context).size.width / 2,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Footer Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: AutoSizeText(
                  footer,
                  textAlign: TextAlign.center,
                  style: transactionTextStyle.copyWith(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Ok Button
              CustomButton(
                text: S.of(context).ok,
                onPressed: onOk,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoPopUp1 extends StatelessWidget {
  final String body;

  const InfoPopUp1({
    super.key,
    this.body = '',
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.vertical,
      onDismissed: (_) => Navigator.of(context).pop(),
      // key: const Key('key'),
      key: UniqueKey(),
      child: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          // height: height,
          width: MediaQuery.of(context).size.width / 1.1,
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              SizedBox(height: 20.h),

              // Body Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: AutoSizeText(
                  body,
                  textAlign: TextAlign.center,
                  style: transactionTextStyle.copyWith(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
