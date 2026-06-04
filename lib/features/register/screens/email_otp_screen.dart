// import 'dart:async';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:touristsaver/common/widgets/custom_app_bar.dart';
// import 'package:touristsaver/common/widgets/custom_button.dart';
// import 'package:touristsaver/common/widgets/custom_snackbar.dart';
// import 'package:touristsaver/common/widgets/otp_timer.dart';
// import 'package:touristsaver/constants/app_text.dart';
// import 'package:touristsaver/constants/global_colors.dart';
// import 'package:touristsaver/constants/read_sms_otp.dart';
// import 'package:touristsaver/constants/style.dart';
// import 'package:touristsaver/features/register/services/dio_register.dart';
// import 'package:touristsaver/models/error_res.dart';
// import 'package:touristsaver/models/request/reg_member_otp_req.dart';
// import 'package:touristsaver/models/request/ver_reg_mem_otp_req.dart';
// import 'package:touristsaver/models/response/common_res.dart';
// import 'package:touristsaver/models/response/ver_reg_mem_otp_res.dart';
// import 'package:sms_autofill/sms_autofill.dart';

// class EmailOTPScreen extends StatefulWidget {
//   static const String routeName = '/email-otp';
//   final int countryID;
//   final int stateID;
//   final String issuerCode;
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String password;
//   final String confirmPassword;
//   final String phonePrefix;
//   final String phNum;
//   final String otpMedium;
//   final String postalCode;
//   final String premium;
//   final String referralCode;
//   const EmailOTPScreen({
//     Key? key,
//     required this.countryID,
//     required this.stateID,
//     required this.issuerCode,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.password,
//     required this.confirmPassword,
//     required this.phonePrefix,
//     required this.phNum,
//     required this.postalCode,
//     required this.premium,
//     required this.referralCode,
//     required this.otpMedium,
//   }) : super(key: key);

//   @override
//   State<EmailOTPScreen> createState() => _EmailOTPScreenState();
// }

// class _EmailOTPScreenState extends State<EmailOTPScreen> {
//   final otpKey = GlobalKey<FormState>();
//   TextEditingController otpController = TextEditingController();
//   late Timer _timer;

//   // For Loading part
//   var isLoadingE = false;
//   String? otp;

//   // For showing the text after 2 minute
//   bool showText = false;
//   bool controlTimer = false;
//   recieveResponseFromTimer() {
//     if (!mounted) return;
//     setState(() {
//       showText = true;
//       controlTimer = true;
//     });
//   }

//   setTimer() {
//     var duration = const Duration(minutes: 2);
//     return Timer(duration, recieveResponseFromTimer);
//   }

//   @override
//   void initState() {
//     SmsAutoFill().unregisterListener();
//     _timer = setTimer();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: CustomAppBar(
//           text: 'Email Verification',
//           // emailVerification,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: otpKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const SizedBox(height: 50),

//               Center(
//                 child: AutoSizeText(
//                   'Email OTP',
//                   // emailOTP,
//                   style: textStyle15.copyWith(fontSize: 20),
//                 ),
//               ),

//               const SizedBox(height: 50),

//               // OTP Text Form Field
//               PinFieldAutoFill(
//                 controller: otpController,
//                 cursor: Cursor(
//                   width: 2,
//                   height: 30,
//                   color: GlobalColors.appColor,
//                   enabled: true,
//                 ),
//                 decoration: UnderlineDecoration(
//                   textStyle: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.black),
//                   colorBuilder: const FixedColorBuilder(
//                     Colors.grey,
//                   ),
//                   lineHeight: 1.5,
//                   gapSpace: 16.0,
//                 ),
//                 currentCode: '',
//                 codeLength: 6,
//                 onCodeChanged: (code) {
//                   otp = code.toString();
//                 },
//               ),

//               const SizedBox(height: 50),

//               // Send Button
//               isLoadingE == true
//                   ? const CustomButtonWithCircular()
//                   : CustomButton(
//                       text: 'Verify',
//                       onPressed: () async {
//                         setState(() {
//                           isLoadingE = true;
//                         });
//                         if (otpKey.currentState!.validate()) {
//                           if (otp != null && otp!.length < 6) {
//                             GlobalSnackBar.valid(
//                                 context, 'Please fill the otp fields!');
//                             setState(() {
//                               isLoadingE = false;
//                             });
//                             return;
//                           }

//                           var res = await DioRegister().verifyEmailOTP(
//                             verifyEmailOtpReqModel: VerifyEmailOtpReqModel(
//                                 phoneNumberPrefix: widget.phonePrefix,
//                                 phoneNumber: widget.phNum,
//                                 email: widget.email,
//                                 emailOtp: otp!,
//                                 countryId: widget.countryID,
//                                 appSign: getAsign),
//                           );

//                           if (!mounted) return;
//                           if (res is VerifyEmailOtpResModel) {
//                             if (res.status == 'Success') {
//                               GlobalSnackBar.showSuccess(context, res.message);
//                               context.pushReplacementNamed('number-reg-otp',
//                                   extra: {
//                                     'countryID': widget.countryID,
//                                     'stateID': widget.stateID,
//                                     'issuerCode': widget.issuerCode,
//                                     'firstName': widget.firstName,
//                                     'lastName': widget.lastName,
//                                     'email': widget.email,
//                                     'password': widget.password,
//                                     'confirmPassword': widget.confirmPassword,
//                                     'phoneNumberPrefix': widget.phonePrefix,
//                                     'phNum': widget.phNum,
//                                     'otpMedium': widget.otpMedium,
//                                     'postalCode': widget.postalCode,
//                                     'premium': widget.premium,
//                                     'referralCode': widget.referralCode,
//                                   });
//                             }
//                           } else if (res is ErrorResModel) {
//                             GlobalSnackBar.showError(context, res.message!);
//                             setState(() {
//                               isLoadingE = false;
//                             });
//                             return;
//                           } else {
//                             GlobalSnackBar.showError(
//                                 context, 'OTP is not valid or Server Error');
//                             setState(() {
//                               isLoadingE = false;
//                             });
//                             return;
//                           }
//                         }
//                       },
//                     ),
//               const SizedBox(height: 20),

//               // Resend Email OTP
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Resend OTP
//                   InkWell(
//                     onTap: () async {
//                       otpController.clear();
//                       setState(() {
//                         showText = false;
//                       });
//                       var res = await DioRegister().resendEmailOTP(
//                         emailmemberOtpReqModel: EmailMemberOtpReqModel(
//                           phoneNumberPrefix: widget.phonePrefix,
//                           phoneNumber: widget.phNum,
//                           email: widget.email,
//                           // countryId: widget.countryID,
//                           memberReferralCode: widget.referralCode,
//                         ),
//                       );
//                       if (!mounted) return;
//                       if (res is CommonResModel) {
//                         if (res.status == 'Success') {
//                           GlobalSnackBar.showSuccess(
//                               context, res.message ?? 'Otp sent successfully!');
//                           setState(() {
//                             setTimer();
//                             controlTimer = false;
//                           });
//                         }
//                       } else {
//                         GlobalSnackBar.showError(
//                             context, 'Error resending OTP');
//                         setState(() {
//                           showText = true;
//                         });
//                       }
//                     },
//                     child: showText
//                         ? Align(
//                             alignment: Alignment.centerRight,
//                             child: Padding(
//                               padding: const EdgeInsets.only(right: 25.0),
//                               child: AutoSizeText(
//                                 'Resend OTP',
//                                 style: textStyle15h.copyWith(
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           )
//                         : const Text(''),
//                   ),

//                   // Timer
//                   controlTimer == false ? const OTPTimer() : const OTPTimer1(),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
