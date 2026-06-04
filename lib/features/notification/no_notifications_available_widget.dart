import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../common/widgets/custom_button.dart';
import '../../constants/global_colors.dart';
import '../../constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class NoNotificationsAvailableWidget extends StatelessWidget {
  const NoNotificationsAvailableWidget({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final String startDate;
  final String endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      margin: const EdgeInsets.all(10),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            child: AutoSizeText(
              S
                  .of(context)
                  .noNotificationFrom
                  .replaceAll('&S', startDate)
                  .replaceAll('&E', endDate),
              textAlign: TextAlign.center,
              style: textStyle15.copyWith(fontSize: 18.sp),
            ),
          ),
          const SizedBox(height: 50),
          Lottie.asset(
            'assets/animations/no_notifications.json',
            height: 130.h,
          ),
          const SizedBox(height: 40),
          CustomButton(
            text: S.of(context).ok,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
