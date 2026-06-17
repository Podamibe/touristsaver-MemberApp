import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/services/dio_common.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/constants/env.dart';
import 'package:touristsaver/constants/fixed_decimal.dart';
import 'package:touristsaver/constants/initialize_stripe.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/read_sms_otp.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/location/services/dio_location.dart';
import 'package:touristsaver/features/register/services/dio_register.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/confirm_topup_req.dart';
import 'package:touristsaver/models/request/register_req.dart';
import 'package:touristsaver/models/request/resend_reg_num_otp_req.dart';
import 'package:touristsaver/models/response/location_get_all.dart';
import 'package:touristsaver/models/response/reg_topup_res.dart';
import 'package:touristsaver/models/response/register_res.dart';
import 'package:touristsaver/models/response/resend_reg_num_otp_res.dart';
import 'package:touristsaver/models/response/stripe_key_res.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'package:touristsaver/generated/l10n.dart';

class NumberOTPScreen extends StatefulWidget {
  static const String routeName = '/number-reg-otp';
  final int countryID;
  final int charityID;
  final int stateID;
  final String issuerCode;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phonePrefix;
  final String phNum;
  final String phoneVerifiedBy;
  final String postalCode;
  final String premium;
  final String referralCode;
  const NumberOTPScreen({
    super.key,
    required this.countryID,
    required this.stateID,
    required this.issuerCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phonePrefix,
    required this.phNum,
    required this.postalCode,
    required this.premium,
    required this.referralCode,
    required this.phoneVerifiedBy,
    required this.charityID,
  });

  @override
  State<NumberOTPScreen> createState() => _NumberOTPScreenState();
}

class _NumberOTPScreenState extends State<NumberOTPScreen> with CodeAutoFill {
  TextEditingController otpControllerr1 = TextEditingController();
  final focusNode = FocusNode();
  var isLoadingN = false;
  bool showText1 = false;
  late Timer _timer;

  recieveResponseFromTimer1() {
    if (!mounted) return;
    setState(() {
      showText1 = true;
    });
  }

  setTimer1() {
    var duration = const Duration(minutes: 2);
    return Timer(duration, recieveResponseFromTimer1);
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
    listenOtp();
    _timer = setTimer1();
    super.initState();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    cancel();
    _timer.cancel();
    // setTimer();
    // listenOtp();
    super.dispose();
  }

  void showPaidFreeScreen() {
    ScaffoldMessenger.of(context).clearSnackBars();
    context.pushReplacementNamed(
      'paid-free',
    );
  }

  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _screenBackground = Color(0xFFF8FAFE);
  static const Color _headlineColor = Color(0xFF101B4D);
  static const Color _softText = Color(0xFF65708D);
  static const Color _fieldBorder = Color(0xFFD8DEEC);

  PinTheme _pinTheme() {
    return PinTheme(
      width: 46.w,
      height: 54.h,
      textStyle: TextStyle(
        color: _headlineColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w800,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _fieldBorder),
      ),
    );
  }

  Widget _gradientVerifyButton({required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [_primaryBlue, _ctaCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: isLoadingN ? null : onPressed,
          child: Center(
            child: isLoadingN
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    S.of(context).verify,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = _pinTheme();
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: _primaryBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: 'Verify Mobile',
          icon: Icons.arrow_back_ios_new,
          onPressed: _returnToRegistrationForm,
        ),
      ),
      backgroundColor: _screenBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58.w,
                      height: 58.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF7FF),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Icon(
                        Icons.verified_user_outlined,
                        color: _primaryBlue,
                        size: 30.sp,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    Text(
                      'Verify your mobile number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _headlineColor,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.16,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Enter the 6-digit code sent to your mobile number.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _softText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        controller: otpControllerr1,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        length: 6,
                        closeKeyboardWhenCompleted: true,
                        pinAnimationType: PinAnimationType.fade,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: defaultPinTheme,
                        separatorBuilder: (index) => SizedBox(width: 8.w),
                        onChanged: (code) {
                          otpControllerr1.text = code;
                        },
                        cursor: Container(
                          width: 2,
                          height: 24.h,
                          color: _primaryBlue,
                        ),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: _fieldBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your verification code will expire in 10 minutes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _headlineColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'You can request a new code if it expires.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _softText,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          if (showText1) ...[
                            SizedBox(height: 10.h),
                            TextButton(
                              onPressed: () async {
                                otpControllerr1.clear();

                                setState(() {
                                  showText1 = false;
                                });
                                var res = await DioRegister().resendNumberOTP(
                                  numberMemberOtpReqModel:
                                      NumberMemberOtpReqModel(
                                    email: widget.email,
                                    phoneNumberPrefix: widget.phonePrefix,
                                    phoneNumber: widget.phNum,
                                    countryId: widget.countryID,
                                    appSign: getAsign,
                                  ),
                                );
                                if (!mounted) return;
                                if (res is ResendRegNumberOtpResModel) {
                                  if (res.status == 'Success') {
                                    setState(() {
                                      _timer = setTimer1();
                                    });
                                    GlobalSnackBar.showSuccess(
                                        context, res.message);
                                  }
                                } else {
                                  GlobalSnackBar.showError(
                                      context,
                                      S
                                          .of(context)
                                          .somethingWentWrongPleaseTryAgain);
                                  setState(() {
                                    showText1 = true;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: _primaryBlue,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                              ),
                              child: Text(
                                S.of(context).resendOtp,
                                style: TextStyle(
                                  color: _primaryBlue,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 28.h),
                    _gradientVerifyButton(
                      onPressed: () async {
                        //    log(otpControllerr1.text);
                        setState(() {
                          isLoadingN = true;
                        });
                        if (otpControllerr1.text.isEmpty) {
                          GlobalSnackBar.valid(
                              context, S.of(context).pleaseFillTheOTPField);
                          setState(() {
                            isLoadingN = false;
                          });
                          return;
                        }
                        var res = await DioRegister().userRegister(
                          registerReqModel: RegisterReqModel(
                            firstname: widget.firstName,
                            lastname: widget.lastName,
                            email: widget.email,
                            password: widget.password,
                            confirmPassword: widget.confirmPassword,
                            postalCode: widget.postalCode,
                            phoneNumberPrefix: widget.phonePrefix,
                            phoneNumber: widget.phNum,
                            phoneVerifiedBy: widget.phoneVerifiedBy,
                            countryId: widget.countryID,
                            stateId: widget.stateID,
                            charityId:
                                widget.charityID == 0 ? null : widget.charityID,
                            issuerCode: widget.issuerCode,
                            memberPremiumCode: widget.premium,
                            memberReferralCode: widget.referralCode,
                            smsotp: otpControllerr1.text.trim(),
                          ),
                        );

                        if (res is RegisterResModel) {
                          // After success sending to the choosing page of free or paid {User or Member will already be created before going to this page}
                          // Saving the token
                          Pref().writeData(
                              key: saveToken, value: res.data!.accessToken!);
                          AppVariables.accessToken = res.data!.accessToken!;
                          Pref().setBool(
                            key: 'showFreePiiinks',
                            value: res.data?.showFreePiiinks ?? false,
                          );
                          AppVariables.showFreePiiinks =
                              res.data?.showFreePiiinks ?? false;
                          // Saving the country ID
                          Pref().writeData(
                              key: saveCountryID,
                              value:
                                  res.data!.memberInfo!.countryId.toString());

                          // Saving the country origin ID
                          Pref().writeData(
                              key: saveCountryOriginID,
                              value: res.data!.memberInfo!.originCountryId
                                  .toString());
                          AppVariables.originCountryId =
                              res.data!.memberInfo!.originCountryId.toString();
                          //Saving the user ID
                          Pref().writeData(
                              key: saveUserID,
                              value: res.data!.memberInfo!.id.toString());
                          Pref().writeData(
                              key: userChosenLocationID,
                              value: widget.countryID.toString());

                          // Calling the location get all Api for saving the user member country currency symbol and country name
                          LocationGetAllResModel? countryCurrency =
                              await DioLocation().getCurrency();
                          await Pref().writeData(
                              key: saveCurrency,
                              value: countryCurrency!.data![0].currencySymbol!);
                          AppVariables.currency =
                              countryCurrency.data![0].currencySymbol!;
                          await Pref().writeData(
                              key: 'saveUsername', value: widget.phNum);
                          await Pref().writeData(
                              key: 'savePassword', value: widget.password);
                          AppVariables.isLocalAuthEnabled = false;
                          //Calling API to fetch the stripe key
                          StripeKeyResModel? getStripeKey =
                              await DioCommon().getStripe();
                          if (getStripeKey is StripeKeyResModel) {
                            Pref().writeData(
                                key: savePublishableKey,
                                value:
                                    getStripeKey.data!.stripePublishableKey ??
                                        stripePublishableKey);

                            initializeFlutterStripe();
                          } else {
                            if (!mounted) return;
                            GlobalSnackBar.showError(
                                context,
                                S
                                    .of(context)
                                    .somethingWentWrongCouldnTFetchTheStripeKeyToCompleteTheRegistrationProcess);
                            setState(() {
                              isLoadingN = false;
                            });
                          }

                          //checking the status and moving to next step
                          if (!mounted) return;
                          // if premium code is provided but not paid
                          // if (res.data!.premiumCodeIsApplied == true &&
                          //     res.data!.premiumCodeIsPaid == false) {

                          if (res.data!.premiumCodeIsApplied == true &&
                              res.data?.discount == "100") {
                            context.pushReplacementNamed(
                              'paid-free',
                            );
                          }
                          // if premium code is provided plus paid
                          // else if (res.data!.premiumCodeIsApplied == true &&
                          //     res.data!.premiumCodeIsPaid == true) {
                          // else if (res.data!.premiumCodeIsApplied == false &&
                          //     res.data!.premiumCodeIsPaid == false) {
                          //   var getRes = await DioRegister().regTopUpStripe(
                          //     registerTopUpStripeReqModel:
                          //         RegisterTopUpStripeReqModel(
                          //       paymentGateway: 'stripe',
                          //       membershipPackageId:
                          //           res.data!.packageId.toString(),
                          //       countryId: widget.countryID.toString(),
                          //       //   memberPremiumCode: widget.premium,
                          //       isTopupUponRegistration: true,
                          //     ),
                          //   );

                          //   if (!mounted) return;
                          //   if (getRes is TopUpStripeResModel) {
                          //     buyPiinkPopUp(
                          //       getRes.clientSecret,
                          //       toFixed2DecimalPlaces(
                          //               res.data!.universalWallet!.balance!)
                          //           .toString(),
                          //     );
                          //     setState(() {
                          //       isLoadingN = false;
                          //     });
                          //   }
                          //   else {
                          //     GlobalSnackBar.showError(context,
                          //         'Something went wrong when validating premium code. Please Try Again Later!!');
                          //     setState(() {
                          //       isLoadingN = false;
                          //     });
                          //   }
                          // }
                          // if premium code is not provided

                          //Yukesh removed this paid-free screen!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                          else {
                            print(
                                "000000001111111111111111111111111111111111111110000000000000000000000000000000000000000000");
                            ScaffoldMessenger.of(context).clearSnackBars();
                            context.pushReplacementNamed(
                              'paid-free',
                            );
                          }
                          // else {
                          //   context.pushReplacementNamed(
                          //     'top-up',
                          //   );
                          // }
                        } else if (res is ErrorResModel) {
                          if (!mounted) return;
                          GlobalSnackBar.showError(context, res.message!);
                          setState(() {
                            isLoadingN = false;
                          });
                          return;
                        }
                        //If registration is not successfully
                        else {
                          if (!mounted) return;
                          GlobalSnackBar.showError(
                              context,
                              S
                                  .of(context)
                                  .somethingWentWrongWhenValidatingPremiumCodePleaseTryAgainLater);
                          setState(() {
                            isLoadingN = false;
                          });
                          return;
                        }
                      },
                    ),
                    SizedBox(height: 22.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F7FF),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        "After mobile verification, we'll send an email verification link to complete your account setup.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _softText,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _returnToRegistrationForm() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.pushReplacementNamed(
      'register',
      queryParameters: {
        'issuercode': widget.issuerCode == 'null' ? '' : widget.issuerCode,
        'memberReferralCode':
            widget.referralCode == 'null' ? '' : widget.referralCode,
      },
    );
  }

  // If applied premium code is paid version
  buyPiinkPopUp(String? clientSecret, String? uniBalance) async {
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
              // height: 520,
              width: MediaQuery.of(context).size.width / 1.1,
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
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
                    S.of(context).touristSaverCreditsInfo,
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
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: AutoSizeText(
                      S
                          .of(context)
                          .congratulationsYouHaveSuccessfullyRegisteredUsingPremiumCodeNextYouCanEitherTopupOrAccountOrContinue,
                      // regPreBody,
                      textAlign: TextAlign.center,
                      style: transactionTextStyle.copyWith(
                        color: Colors.black.withValues(alpha: 0.7),
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Image
                  SizedBox(
                    // color: Colors.orange,
                    child: Image.asset(
                      "assets/images/shopping-bag.png",
                      height: 130,
                      width: MediaQuery.of(context).size.width / 2,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 40),

                  CustomButton(
                    text: S.of(context).continueL,
                    onPressed: () {
                      if (!mounted) return;

                      context.pushReplacementNamed('congrats-screen',
                          pathParameters: {'piiinkCredit': uniBalance!});
                    },
                  ),
                  const SizedBox(height: 15),
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
        var sheetRes =
            await Stripe.instance.retrievePaymentIntent(clientSecret!);
        if (sheetRes.status == PaymentIntentsStatus.Succeeded) {
          // Confirming the stripe payment in backend
          var confirm = await DioRegister().regTopup(
              regTopUpReqModel: ConfirmTopUpReqModel(
                  paymentIntent: sheetRes.id,
                  paymentIntentClientSecret: sheetRes.clientSecret));

          if (!mounted) return;
          if (confirm is RegTopUpResModel) {
            if (confirm.status == 'success') {
              context.pushReplacementNamed('congrats-screen', pathParameters: {
                'piiinkCredit': toFixed2DecimalPlaces(
                        confirm.data!.universalWallet!.balance!)
                    .toString()
              });
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
        var sheetRes =
            await Stripe.instance.retrievePaymentIntent(clientSecret!);
        var confirm = await DioRegister().regTopup(
            regTopUpReqModel: ConfirmTopUpReqModel(
                paymentIntent: sheetRes.id,
                paymentIntentClientSecret: sheetRes.clientSecret));
        if (!mounted) return;

        if (confirm is RegTopUpResModel) {
          if (confirm.status != 'success') {
            GlobalSnackBar.showError(context, S.of(context).paymentFailed);
          } else {
            GlobalSnackBar.showError(context, S.of(context).paymentFailed);
          }
        } else {
          GlobalSnackBar.showError(
              context, S.of(context).thePaymentHasBeenCanceled);
        }
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }
}
