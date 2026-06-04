import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/generated/l10n.dart';

class NoMerchantCard extends StatelessWidget {
  final String? text;
  const NoMerchantCard({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      // width: MediaQuery.of(context).size.width / 1.175,
      margin: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      height: 80,
      decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                offset: const Offset(2, 2),
                spreadRadius: 1,
                blurRadius: 1)
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/no-merchant.png',
            height: 50,
          ),
          const SizedBox(width: 10),
          AutoSizeText(text ?? S.of(context).noMerchantAvailable,
              style: TextStyle(
                  color: GlobalColors.gray.withValues(alpha: 0.7),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600))
        ],
      ),
    ));
  }
}
