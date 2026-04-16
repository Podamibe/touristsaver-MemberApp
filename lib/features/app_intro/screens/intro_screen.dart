import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/generated/l10n.dart';

// Make sure to import wherever your checkWalletBalance() and AppVariables live
import '../../../common/app_variables.dart';
import 'package:new_piiink/splash_screen.dart'; // Adjust if checkWalletBalance is elsewhere

class IntroScreen extends StatelessWidget {
  static const String routeName = '/intro-screen';
  const IntroScreen({super.key});

  // 👉 NEW: Helper method to handle routing after Intro is done or skipped
  Future<void> _finishIntroAndNavigate(BuildContext context) async {
    Pref pref = Pref();
    // Save "acc" as true so next time splash skips video + intro
    await pref.writeData(key: accept, value: 'true');

    // 1. Check if the user is logged in
    String? token = await pref.readData(key: saveToken);
    bool isLoggedIn = token != null && token.isNotEmpty;

    if (isLoggedIn) {
      // 2. Check their wallet balance if they are logged in
      bool canGoHome = await checkWalletBalance();

      if (!context.mounted) return;

      if (canGoHome) {
        context.goNamed('bottom-bar', pathParameters: {'page': '0'});
      } else {
        context.goNamed('top-up'); // redirect to top up / warning
      }
    } else {
      if (!context.mounted) return;
      // 3. Not logged in, send to login screen
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 80.h),
        decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(2, 2))
            ]),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: IntroductionScreen(
            globalBackgroundColor: GlobalColors.appWhiteBackgroundColor,
            pages: [
              // First
              PageViewModel(
                title: S.of(context).welcomeToTouristSaver,
                // 'Welcome to Piiink',
                body: S
                    .of(context)
                    .theMostInnovativeCommunityLifestyleProgramForYourEverydayShopping,
                // 'The most innovative Community Lifestyle Program for your everyday shopping.',
                image: piiinkBuildImage("assets/images/tourist.png", context),
                //getPageDecoration, a method to customise the page style
                decoration: getPageDecoration(),
              ),
              // //  Second
              // PageViewModel(
              //   title: S.of(context).goShopping,
              //   //'Go shopping',
              //   body:
              //       S.of(context).shopAtTouristSaverMerchantsAndGetGreatOffers,
              //   // 'Shop at Piiink merchants and get great offers.',
              //   image: buildImage("assets/images/shopping-bag.png", context),
              //   decoration: getPageDecoration(),
              // ),
              // // Third
              // PageViewModel(
              //   title: S.of(context).donateToCharity,
              //   // 'Donate to charity',
              //   body: S
              //       .of(context)
              //       .fromEveryTransactionCashGoesToYourNominatedCharity,
              //   //  'From every transaction, cash goes to your nominated charity.',
              //   image: buildImage("assets/images/charity.png", context),
              //   decoration: getPageDecoration(),
              // ),
            ],

            // 👉 UPDATED: Call the helper function on Done
            onDone: () => _finishIntroAndNavigate(context),

            // 👉 NEW: Also call it on Skip so users don't get stuck!
            onSkip: () => _finishIntroAndNavigate(context),

            // Done
            showDoneButton: true,
            done: Container(
              height: 35.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: GlobalColors.appColor1,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: AutoSizeText(
                  S.of(context).continueL,
                  // 'Continue',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Next
            showNextButton: true,
            next: Container(
              height: 35.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: GlobalColors.appColor1,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: AutoSizeText(
                  S.of(context).next,
                  // 'Next',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Skip
            showSkipButton: true,
            skip: AutoSizeText(S.of(context).skip,
                //'Skip',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: GlobalColors.textColor,
                    fontSize: 15.sp)),
          ),
        ),
      ),
    );
  }

  // Widget to add the image on intro screen
  Widget piiinkBuildImage(String imagePath, context) {
    return Container(
      // width: MediaQuery.of(context).size.width / 1.9,
      width: 200.w,
      // height: 250.h,
      color: Colors.white,
      child: Image.asset(imagePath, fit: BoxFit.fill),
    );
  }

  // Widget to add the image on intro screen
  Widget buildImage(String imagePath, context) {
    return Container(
      // width: MediaQuery.of(context).size.width / 1.9,
      width: 100.w,
      // height: 250.h,
      color: Colors.white,
      child: Image.asset(imagePath, fit: BoxFit.fill),
    );
  }

  //method to customise the page style
  PageDecoration getPageDecoration() {
    return PageDecoration(
      imagePadding: const EdgeInsets.only(top: 50),
      titleTextStyle: TextStyle(
          color: GlobalColors.textColor,
          fontSize: 23.sp,
          fontWeight: FontWeight.bold),
      bodyPadding:
          const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      bodyTextStyle: TextStyle(
          color: GlobalColors.textColor,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600),
    );
  }
}
