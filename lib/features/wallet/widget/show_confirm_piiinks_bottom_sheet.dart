// ignore_for_file: use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/constants/decimal_remove.dart';
import 'package:touristsaver/constants/number_formatter.dart';
import 'package:touristsaver/features/wallet/services/dio_wallet.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_snackbar.dart';
// import '../features/profile/services/dio_profile.dart';
// import '../models/response/common_res.dart';
// import 'widgets/custom_button.dart';
import 'package:touristsaver/generated/l10n.dart';

Future<dynamic> showConfirmPiiinksBottomSheet(
    BuildContext context, double? universalFreePiiinks) {
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
                S.of(context).claimFreeTouristSavers,
                // 'Claim Free Piiinks',
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
                  S
                      .of(context)
                      .youHavenotClaimedYourUPFreeUniversalPiinksYet
                      .replaceAll(
                          '*UP',
                          removeTrailingZero(
                              numFormatter.format(universalFreePiiinks))),
                  // "You haven't claimed your $universalFreePiiinks free Universal Piinks yet.",
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
                "assets/images/shopping-bag.png",
                height: 150.h,
                width: MediaQuery.of(context).size.width * 0.3,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30.h),
              apiCalled == true
                  ? const CustomButtonWithCircular()
                  : ModalCustomButton(
                      text: S.of(context).claimNow,
                      // 'Claim Now',
                      onPressed: () async {
                        setState(() {
                          apiCalled = true;
                        });
                        await DioWallet().confirmPiiinks().then((value) {
                          if (value!.status == 'success') {
                            context.pop();
                            context.pushReplacementNamed('congrats-screen',
                                pathParameters: {
                                  'piiinkCredit':
                                      value.universalPiiinks.toString(),
                                });
                            GlobalSnackBar.showSuccess(
                                context,
                                S
                                    .of(context)
                                    .freeTouristSaversClaimedSuccessfully);
                          } else {
                            context.pop();
                            setState(() {
                              apiCalled = true;
                            });
                            GlobalSnackBar.showError(
                                context, S.of(context).someErrorOccurred);
                          }
                        });
                        // if (result is ClaimPiiinksResModel) {
                        //   if (result.status == 'Success') {
                        //     log(result.status.toString());
                        //     context.pushReplacementNamed('congrats-screen',
                        //         pathParameters: {
                        //           'piiinkCredit':
                        //               result.universalPiiinks.toString(),
                        //         });
                        //     GlobalSnackBar.showSuccess(
                        //         context, 'Piiinks claimed successfully.');
                        //   }
                        // } else if (result is ErrorResModel) {
                        //   GlobalSnackBar.showError(
                        //       context, 'Some error occurred!');
                        // } else {
                        //   GlobalSnackBar.showError(
                        //       context, 'Some error occurred!');
                        // }
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
