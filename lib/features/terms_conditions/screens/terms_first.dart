import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/terms_conditions/widgets/text.dart';
import 'package:touristsaver/generated/l10n.dart';

class TermsFirst extends StatefulWidget {
  static const String routeName = '/terms-first';
  const TermsFirst({super.key});

  @override
  State<TermsFirst> createState() => _TermsFirstState();
}

class _TermsFirstState extends State<TermsFirst> {
  String acceptForOne =
      'true'; //to check whether the user as accepted policy or not
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(text: S.of(context).termsConditions),
      ),
      body: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          width: MediaQuery.of(context).size.width / 1,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
          child: wholePage(),
        ),
      ),
    );
  }

  wholePage() {
    return ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: GlobalColors.appColor,
                      checkColor: Colors.white,
                      side: const BorderSide(
                        color: GlobalColors.appColor,
                        width: 2,
                      ),
                      // fillColor:
                      //     WidgetStateProperty.all(GlobalColors.appColor),
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    AutoSizeText.rich(
                      TextSpan(
                        text: S.of(context).byClicking,
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.8),
                            fontFamily: 'Sans'),
                        children: [
                          TextSpan(
                            text: ' Agree and Continue :',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(left: 52.0),
                  child: AutoSizeText.rich(
                    TextSpan(
                      text: '• I hereby agree and consent to the ',
                      style: textStyle15h.copyWith(fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: S.of(context).termsAndConditions,
                          style: textStyle15h.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: GlobalColors.appColor,
                            color: GlobalColors.appColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap =
                                () => context.pushNamed('terms-condition'),
                        ),
                        TextSpan(
                          text: ' of Piiink.',
                          style: textStyle15h.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(left: 52.0),
                  child: AutoSizeText(
                    secondLine,
                    style: textStyle15h.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 52.0),
                  child: AutoSizeText(
                    thirdLine,
                    style: textStyle15h.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 30),

                //Accept action button
                isLoading == true
                    ? const CustomButtonWithCircular()
                    : CustomButton(
                        text: S.of(context).agreeAndContinue,
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          if (formKey.currentState!.validate()) {
                            if (isChecked == false) {
                              GlobalSnackBar.valid(context,
                                  S.of(context).pleaseAcceptTermsConditions);
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            Pref().writeData(key: accept, value: acceptForOne);
                            context.goNamed('bottom-bar',
                                pathParameters: {'page': '0'});
                          }
                        },
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
