// ignore_for_file: use_build_context_synchronously

// import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/models/error_res.dart';

import '../features/profile/services/dio_profile.dart';
import '../models/response/common_res.dart';
import 'widgets/custom_button.dart';
import 'package:touristsaver/generated/l10n.dart';

Future<dynamic> showVerifyEmailBottomSheet(BuildContext context,
    {String? message}) {
  return showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      bool apiCalled = false;
      return StatefulBuilder(builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15.h),
              Container(
                width: 65.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50)),
              ),
              SizedBox(height: 15.h),
              AutoSizeText(
                S.of(context).verifyEmail,
                // 'Verify Email',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black.withValues(alpha: 0.8),
                    fontFamily: 'Sans'),
              ),
              SizedBox(height: 25.h),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: AutoSizeText(
                  message ?? S.of(context).yourEmailIsNotActivatedYet,
                  // message ??
                  //     'Your email is not activated yet.\n'
                  //         'You need to activate your email to change country and recommend merchant '
                  //         'as well as to receive important emails from Piiink.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                      decoration: TextDecoration.none,
                      color: Colors.black.withValues(alpha: 0.5),
                      fontFamily: 'Sans'),
                ),
              ),
              SizedBox(height: 30.h),
              Image.asset(
                "assets/images/mail.png",
                height: 150.h,
                width: MediaQuery.of(context).size.width * 0.3,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30.h),
              apiCalled == true
                  ? const CustomButtonWithCircular()
                  : ModalCustomButton(
                      text: S.of(context).verifyNow,
                      // text: 'Verify Now',
                      onPressed: () async {
                        setState(() {
                          apiCalled = true;
                        });
                        var result = await DioProfile().verifyEmail();
                        context.pop();
                        if (result is CommonResModel) {
                          if (result.status == 'Success') {
                            // log(result.message!);
                            GlobalSnackBar.showSuccess(
                                context,
                                result.message ??
                                    S
                                        .of(context)
                                        .verificationLinkSentSuccessfully);
                          }
                        } else if (result is ErrorResModel) {
                          // log(result.message!);
                          GlobalSnackBar.showError(
                              context,
                              result.message ??
                                  S.of(context).someErrorOccurred);
                        } else {
                          GlobalSnackBar.showError(
                              context, S.of(context).someErrorOccurred);
                        }
                      },
                    ),
              SizedBox(height: 15.h),
            ],
          ),
        );
      });
    },
  );
}
