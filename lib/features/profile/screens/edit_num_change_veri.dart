import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/services/dio_common.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/otp_timer.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/read_sms_otp.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/register/services/dio_register.dart';
import 'package:touristsaver/models/request/resend_reg_num_otp_req.dart';
import 'package:touristsaver/models/request/ver_num_changed_req.dart';
import 'package:touristsaver/models/response/resend_reg_num_otp_res.dart';
import 'package:touristsaver/models/response/ver_num_changed_res.dart';
import 'package:pinput/pinput.dart';
import 'package:touristsaver/generated/l10n.dart';

import 'package:sms_autofill/sms_autofill.dart';

class EditNumberChangedVerification extends StatefulWidget {
  static const String routeName = '/edit-number';
  final String phoneNumberPrefix;
  final String mobileNumber;
  final String email;
  final int countryId;
  const EditNumberChangedVerification({
    super.key,
    required this.mobileNumber,
    required this.email,
    required this.countryId,
    required this.phoneNumberPrefix,
  });

  @override
  State<EditNumberChangedVerification> createState() =>
      _EditNumberChangedVerificationState();
}

class _EditNumberChangedVerificationState
    extends State<EditNumberChangedVerification> with CodeAutoFill {
  final numberOTPKey = GlobalKey<FormState>();
  TextEditingController otpControllerr1 = TextEditingController();
  final focusNode = FocusNode();

  // For loading part
  var isLoading = false;

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

  @override
  void codeUpdated() {
    //for reading the updated sms otp
    setState(() {
      smsCode = code.toString();
      otpControllerr1.text = smsCode;
    });
  }

  // to detect the sms otp code
  void listenOtp() async {
    listenForCode();
    SmsAutoFill().listenForCode;
  }

  @override
  void initState() {
    setTimer();
    listenOtp();
    super.initState();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    cancel();
    // setTimer();
    // listenOtp();
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

              SizedBox(height: 50.h),

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
                    //  smsCode = code.toString();
                    otpControllerr1.text = code;
                  },
                  cursor: Container(
                    width: 2,
                    height: 25,
                    color: GlobalColors.appColor,
                  ),
                ),
              ),

              const SizedBox(height: 50),

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
                              phoneNumberPrefix: widget.phoneNumberPrefix,
                              smsotp: otpControllerr1.text,
                            ),
                          );

                          if (!mounted) return;
                          if (res is VerifyChangedNumberResModel) {
                            if (res.status == 'update success') {
                              GlobalSnackBar.showSuccess(context,
                                  S.of(context).profileUpdatedSuccessfully);
                              context.pushReplacementNamed('bottom-bar',
                                  pathParameters: {'page': '4'});
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

              const SizedBox(height: 20),

              // Cancel Button
              CustomButton1(
                text: S.of(context).cancel,
                onPressed: () {
                  showDialog(
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
                              onPressed: () {
                                GlobalSnackBar.showSuccess(context,
                                    S.of(context).profileUpdatedSuccessfully);
                                context.pushReplacementNamed('bottom-bar',
                                    pathParameters: {'page': '4'});
                              },
                              text: S.of(context).yes,
                            ),
                            const SizedBox(height: 10),
                            // No Button
                            CustomButton1(
                              onPressed: () {
                                context.pop();
                              },
                              text: S.of(context).no,
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Resend Email OTP
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
                          phoneNumberPrefix: widget.phoneNumberPrefix,
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
                            //    listenOtp();
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
                              child: Text(
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
}
