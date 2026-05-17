import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/services/dio_common.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_button.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/common/widgets/otp_timer.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/read_sms_otp.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/register/services/dio_register.dart';
import 'package:new_piiink/features/top_up/services/top_up_dio.dart';
import 'package:new_piiink/models/request/confirm_topup_req.dart';
import 'package:new_piiink/models/request/resend_reg_num_otp_req.dart';
import 'package:new_piiink/models/request/top_up_stripe_req.dart';
import 'package:new_piiink/models/request/ver_num_changed_req.dart';
import 'package:new_piiink/models/response/confirm_topup_res.dart';
import 'package:new_piiink/models/response/member_package_res.dart';
import 'package:new_piiink/models/response/resend_reg_num_otp_res.dart';
import 'package:new_piiink/models/response/top_up_stripe_res.dart';
import 'package:new_piiink/models/response/ver_num_changed_res.dart';
import 'package:pinput/pinput.dart';
import 'package:new_piiink/generated/l10n.dart';

import 'package:sms_autofill/sms_autofill.dart';

class CountryNumberChangedVerification extends StatefulWidget {
  static const String routeName = '/country-number-edit';
  final String phonePrefix;
  final String mobileNumber;
  final String email;
  final int countryId;
  const CountryNumberChangedVerification({
    super.key,
    required this.mobileNumber,
    required this.email,
    required this.countryId,
    required this.phonePrefix,
  });

  @override
  State<CountryNumberChangedVerification> createState() =>
      _CountryNumberChangedVerificationState();
}

class _CountryNumberChangedVerificationState
    extends State<CountryNumberChangedVerification> with CodeAutoFill {
  final numberOTPKey = GlobalKey<FormState>();
  TextEditingController otpControllerr1 = TextEditingController();
  final focusNode = FocusNode();

  // For Loading part
  var isLoading = false;
  var isLoadingB = false; //For Buy Piink Pop Up

  // For showing the text after 2 minute
  bool showText = false;
  bool controlTimer = false;
  recieveResponseFromTimer() {
    if (!mounted) return;
    setState(() {
      showText = true;
      controlTimer = true;
    });
  }

  setTimer() {
    var duration = const Duration(minutes: 2);
    return Timer(duration, recieveResponseFromTimer);
  }

  //Reading the sms otp
  String smsCode = '';

  // Listen for incoming SMS messages
  void listenOtp() async {
    listenForCode();
    SmsAutoFill().listenForCode;
  }

  @override
  void codeUpdated() {
    //for reading the updated sms otp
    setState(() {
      smsCode = code.toString();
      otpControllerr1.text = smsCode;
    });
  }

  @override
  void initState() {
    setTimer();
    listenOtp();
    super.initState();
  }

  @override
  void dispose() {
    setTimer();
    otpControllerr1.dispose();
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).mobileNumberVerification,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: numberOTPKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              Center(
                child: AutoSizeText(
                  S.of(context).enterTheOtpThatHasBeenSentInYourMobileNumber,
                  style: textStyle15.copyWith(fontSize: 20),
                ),
              ),

              const SizedBox(height: 50),

              //OTP Code Field
              // PinFieldAutoFill(
              //   controller: otpControllerr1,
              //   cursor: Cursor(
              //     width: 2,
              //     height: 30,
              //     color: GlobalColors.appColor,
              //     enabled: true,
              //   ),
              //   decoration: UnderlineDecoration(
              //     textStyle: const TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w400,
              //         color: Colors.black),
              //     colorBuilder: const FixedColorBuilder(
              //       Colors.grey,
              //     ),
              //     lineHeight: 1.5,
              //     gapSpace: 16.0,
              //   ),
              //   currentCode: smsCode,
              //   codeLength: 6,
              //   onCodeChanged: (code) {
              //     setState(() {
              //       smsCode = code.toString();
              //     });
              //   },
              // ),

              Directionality(
                // Specify direction if desired
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: otpControllerr1,
                  focusNode: focusNode,
                  keyboardType: TextInputType.phone,
                  length: 6,
                  closeKeyboardWhenCompleted: true,
                  pinAnimationType: PinAnimationType.fade,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  // androidSmsAutofillMethod:
                  //     AndroidSmsAutofillMethod.smsRetrieverApi,
                  // listenForMultipleSmsOnAndroid: true,
                  //    defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  onChanged: (code) {
                    otpControllerr1.text = code;
                  },
                  cursor: Container(
                    width: 2,
                    height: 25,
                    color: GlobalColors.appColor,
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              // Send Button
              isLoading == true
                  ? const CustomButtonWithCircular()
                  : CustomButton(
                      text: S.of(context).verifyMobileNumber,
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (numberOTPKey.currentState!.validate()) {
                          if (otpControllerr1.text.isEmpty) {
                            GlobalSnackBar.valid(
                                context, S.of(context).pleaseFillTheOTPField);
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          var res = await DioCommon().editProfile(
                            verifyChangedNumberReqModel:
                                VerifyChangedNumberReqModel(
                              phoneNumber: widget.mobileNumber,
                              phoneNumberPrefix: widget.phonePrefix,
                              smsotp: otpControllerr1.text,
                            ),
                          );
                          if (!mounted) return;
                          if (res is VerifyChangedNumberResModel) {
                            if (res.status == 'update success') {
                              GlobalSnackBar.showSuccess(context,
                                  S.of(context).countryChangedSuccessfully);
                              if (widget.countryId ==
                                  int.parse(AppVariables.originCountryId!)) {
                                context.pushReplacementNamed('bottom-bar',
                                    pathParameters: {'page': '3'});
                              } else {
                                buyPiinkPopUp();
                                GlobalSnackBar.showSuccess(context,
                                    S.of(context).countryChangedSuccessfully);
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          } else {
                            GlobalSnackBar.showError(context,
                                S.of(context).verficationFailedTryAgain);
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                    ),

              SizedBox(height: 20.h),

              // Cancel Button
              CustomButton1(
                text: S.of(context).cancel,
                onPressed: () {
                  cancelPopUp();
                },
              ),
              SizedBox(height: 20.h),
              // Resend Number OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Resend OTP
                  InkWell(
                    onTap: () async {
                      otpControllerr1.clear();
                      setState(() {
                        showText = false;
                      });
                      var res = await DioRegister().resendNumberOTP(
                        numberMemberOtpReqModel: NumberMemberOtpReqModel(
                          email: widget.email,
                          phoneNumberPrefix: widget.phonePrefix,
                          phoneNumber: widget.mobileNumber,
                          countryId: widget.countryId,
                          appSign: getAsign,
                        ),
                      );
                      if (!mounted) return;
                      if (res is ResendRegNumberOtpResModel) {
                        if (res.status == 'Success') {
                          GlobalSnackBar.showSuccess(context, res.message);
                          setState(() {
                            //     listenOtp();
                            setTimer();
                            controlTimer = false;
                          });
                        }
                      } else {
                        GlobalSnackBar.showError(
                            context, S.of(context).errorResendingOtp);
                        setState(() {
                          showText = true;
                        });
                      }
                    },
                    child: showText
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 25.0),
                              child: AutoSizeText(
                                S.of(context).resendOtp,
                                style: textStyle15h.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          )
                        : const Text(''),
                  ),
                  // Timer
                  controlTimer == false ? const OTPTimer() : const OTPTimer1(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // cancel button pop up
  cancelPopUp() {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
          S
              .of(context)
              .ifYouClickOnCancelYourMobileNumberWonTBeVerifiedAndOnlyTheOtherChangesWillBeDone,
          textAlign: TextAlign.center,
          style: topicStyle,
        ),
        actions: [
          Column(
            children: [
              // Yes Button
              CustomButton(
                onPressed: () async {
                  GlobalSnackBar.showSuccess(
                      context, S.of(context).updatedSuccessfully);
                  context.pushReplacementNamed('bottom-bar',
                      pathParameters: {'page': '3'});
                },
                text: S.of(context).yes,
              ),
              const SizedBox(height: 10),
              // No Button
              CustomButton1(
                onPressed: () {
                  context.pop(context);
                },
                text: S.of(context).no,
              ),
            ],
          )
        ],
      ),
    );
  }

  // After Successfully change of the country
  buyPiinkPopUp() async {
    // Reading the saved country currency right after the writing when changing country
    // print("countryID");
    // print(countryID);
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: false, //to dismiss the container once opened
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Container(
              // height: 500,
              width: MediaQuery.of(context).size.width / 1.1,
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                  // title Text
                  AutoSizeText(
                    S.of(context).touristSaverCreditsInfo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        decoration: TextDecoration.none,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontFamily: 'Sans'),
                  ),
                  SizedBox(height: 15.h),
                  // Body Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Text(
                      S
                          .of(context)
                          .topUpUniversalTouristSaverCreditsToGetDiscountWithAnyOfOurMerchant,
                      textAlign: TextAlign.center,
                      style: transactionTextStyle.copyWith(
                        color: Colors.black.withValues(alpha: 0.7),
                        fontSize: 18,
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                  // Image
                  SizedBox(
                    // color: Colors.orange,
                    child: Image.asset(
                      "assets/images/shopping-bag.png",
                      height: 130.h,
                      width: MediaQuery.of(context).size.width / 2,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Top Up Button
                  StatefulBuilder(builder: (context, stateMod) {
                    return FutureBuilder<MemberShipPackageResModel?>(
                        future: DioTopUpStripe().memPack(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CustomButton(text: S.of(context).pleaseWait);
                          } else {
                            var memPackAll = snapshot.data!;
                            return memPackAll.data!.isEmpty
                                ? CustomButton(
                                    text: S.of(context).noTopUpAvailable,
                                    onPressed: () {
                                      // Navigator.pushAndRemoveUntil(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             const BottomBar()),
                                      //     ((route) => false));
                                      // GlobalSnackBar.showSuccess(
                                      //     context, 'Country Changed Successfully');
                                    },
                                  )
                                : isLoadingB == true
                                    ? const CustomButtonWithCircular()
                                    : CustomButton(
                                        text: S
                                            .of(context)
                                            .topUpAndPayXY
                                            .replaceAll('&XY',
                                                '${AppVariables.currency}${memPackAll.data![0].packageFee.toString()} inc GST'),
                                        onPressed: () async {
                                          stateMod(() {
                                            isLoadingB = true;
                                          });
                                          var res = await DioTopUpStripe()
                                              .topUpStripe(
                                            topUpStripeReqModel:
                                                TopUpStripeReqModel(
                                                    paymentGateway: 'stripe',
                                                    membershipPackageId:
                                                        memPackAll.data![0].id
                                                            .toString(),
                                                    countryId: widget.countryId
                                                        .toString()),
                                          );
                                          if (!mounted) return;
                                          if (res is TopUpStripeResModel) {
                                            await Stripe.instance
                                                .initPaymentSheet(
                                                    paymentSheetParameters:
                                                        SetupPaymentSheetParameters(
                                              paymentIntentClientSecret:
                                                  res.clientSecret,
                                              // applePay: const PaymentSheetApplePay(
                                              //     merchantCountryCode: 'DE'),
                                              // googlePay: const PaymentSheetGooglePay(
                                              //     merchantCountryCode: 'DE', testEnv: true),
                                              merchantDisplayName: 'Prospects',
                                              style: ThemeMode.dark,
                                              // returnURL:
                                              //     'https://piiink-backend.demo-4u.net/api/$stripePayConfirm',
                                            ));
                                            stateMod(() {
                                              isLoadingB = false;
                                            });
                                            await displayPaymentSheet(
                                                res.clientSecret);
                                          } else {
                                            GlobalSnackBar.showError(context,
                                                S.of(context).serverError);
                                            stateMod(() {
                                              isLoadingB = false;
                                            });
                                          }
                                        },
                                      );
                          }
                        });
                  }),
                  SizedBox(height: 20.h),
                  // Free Button
                  CustomButton(
                    text: S.of(context).continueWithDefaultTouristSaverCredits,
                    onPressed: () {
                      if (!mounted) return;
                      context.pushReplacementNamed('bottom-bar',
                          pathParameters: {'page': '3'});
                      GlobalSnackBar.showSuccess(
                          context, S.of(context).countryChangedSuccessfully);
                    },
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  // For Top Up
  Future<void> displayPaymentSheet(String? clientSecret) async {
    try {
      //this shows the stripe pay form
      await Stripe.instance.presentPaymentSheet().then((value) async {
        //Retreiving the response after stripe sheet pay button is clicked

        var res = await Stripe.instance.retrievePaymentIntent(clientSecret!);
        if (res.status == PaymentIntentsStatus.Succeeded) {
          // Confirming the stripe payment in backend
          var confirm = await DioTopUpStripe().confirmTopUp(
              confirmTopUpReqModel: ConfirmTopUpReqModel(
                  paymentIntent: res.id,
                  paymentIntentClientSecret: res.clientSecret));
          if (!mounted) return;
          if (confirm is ConfirmTopUpResModel) {
            if (confirm.status == 'success') {
              // Navigating
              context.pushReplacementNamed('bottom-bar',
                  pathParameters: {'page': '3'});
              // Message
              GlobalSnackBar.showSuccess(
                  context, S.of(context).paymentSuccessful);
            } else {
              GlobalSnackBar.showError(context, S.of(context).paymentFailed);
            }
          } else {
            GlobalSnackBar.showError(context, S.of(context).serverError);
          }
        } else {
          if (!mounted) return;
          GlobalSnackBar.showError(context, S.of(context).stripePaymentFail);
        }
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        var res = await Stripe.instance.retrievePaymentIntent(clientSecret!);
        // print(res);

        // Confirming the stripe payment in backend
        var confirm = await DioTopUpStripe().confirmTopUp(
            confirmTopUpReqModel: ConfirmTopUpReqModel(
                paymentIntent: res.id,
                paymentIntentClientSecret: res.clientSecret));
        if (!mounted) return;
        if (confirm is ConfirmTopUpResModel) {
          if (confirm.status == 'failed') {
            GlobalSnackBar.showError(context, S.of(context).paymentFailed);
          } else {
            GlobalSnackBar.showError(context, S.of(context).paymentFailed);
          }
        } else {
          GlobalSnackBar.showError(
              context, S.of(context).thePaymentHasBeenCanceled);
        }
        // print("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        // print("Unforeseen error: ${e}");
        return;
      }
    } catch (e) {
      // print("exception:$e");
      return;
    }
  }
}
