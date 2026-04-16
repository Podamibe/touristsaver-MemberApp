import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/constants/read_sms_otp.dart';
import 'package:new_piiink/features/wallet/services/dio_wallet.dart';
import 'package:new_piiink/models/response/universal_get_my_wallet.dart';

import 'common/app_variables.dart';

String? acc;

class MySplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

Future<bool> checkWalletBalance() async {
  try {
    DioWallet dioWallet = DioWallet();
    UniversalGetMyWallet? wallet = await dioWallet.getUniverslUserWallet();

    double balance = wallet?.data?.balance ?? 0;
    debugPrint("💰 User balance: $balance");

    // Return true only if balance > 0
    return balance > 0;
  } catch (e) {
    debugPrint("❌ Error fetching wallet: $e");
    return false; // default to false to avoid navigating to home
  }
}

class _MySplashScreenState extends State<MySplashScreen> {
  //Using in_app_update package for force update only in android
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // AppUpdateInfo? updateInfo;
  late AppLifecycleState appLifecycleState;
  // bool flexibleUpdateAvailable = false;
  // Splash time
  int splashtime = 1;

  // Future<void> checkForUpdate() async {
  //   InAppUpdate.checkForUpdate().then((info) {
  //     if (info.updateAvailability == UpdateAvailability.updateAvailable) {
  //       if (Platform.isAndroid) {
  //         InAppUpdate.performImmediateUpdate().then((value) {
  //           if (value.name == 'success') {
  //             showSnack(value.name);
  //           }
  //         }).catchError((e) => showSnack(e));
  //       }
  //     }
  //   }).catchError((e) {
  //     showSnack(e.toString());
  //   });
  // }

  // void showSnack(
  //   String text,
  // ) {
  //   if (navigatorKey.currentContext != null) {
  //     ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
  //         // action: SnackBarAction(
  //         //     label: 'Restart',
  //         //     textColor: GlobalColors.appWhiteBackgroundColor,
  //         //     onPressed: () {
  //         //       // Restart app logic
  //         //       Restart.restartApp();
  //         //     }),
  //         backgroundColor: Colors.green,
  //         // duration: const Duration(minutes: 5),
  //         content: Text(
  //           text,
  //           style: const TextStyle(color: GlobalColors.appWhiteBackgroundColor),
  //         )));
  //   }
  // }

  // Navigator to intro screen
  void showIntroVideo() {
    context.pushReplacementNamed(
      'video-screen',
    );
  }

  void showIntro() {
    context.pushReplacementNamed(
      'intro-screen',
    );
  }

  // Navigator to home screen
  void showBottomBar() async {
    context.pushReplacementNamed(
      'bottom-bar',
      pathParameters: {"page": "0"},
    );
  }

  void showlogin() async {
    context.pushReplacementNamed(
      'login',
    );
  }

  @override
  void initState() {
    // Checking whether the user has accepted the terms and condition or not
    // It will be called only once after Build widgets done with rendering and setState is called to rebuild the widget
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await checkForUpdate();
      Pref pref = Pref();
      AppVariables.isLocalAuthEnabled =
          await pref.readBool(key: 'saveLocalAuth');
      acc = await pref.readData(key: accept);
      int? notificationsCount = await pref.readInt(key: 'notificationsCount');
      AppVariables.selectedLanguageNow = await Pref().readData(key: 'locale');
      if (notificationsCount != null && notificationsCount != 0) {
        AppVariables.notificationLabel.value = notificationsCount;
      }
      String? token = await pref.readData(key: saveToken);
      bool isLoggedIn = token != null && token.isNotEmpty;
      bool canGoHome = await checkWalletBalance();

      // Wait splash time before deciding where to go
      Timer(Duration(seconds: splashtime), () async {
        if (acc == 'true') {
          if (isLoggedIn) {
            if (canGoHome) {
              showBottomBar();
            } else {
              showTopUpScreen(); // redirect to top up / warning
            }
          } else {
            showlogin();
          }
        } else {
          showIntroVideo();
        }
      });
    });

    getAppSign(); //Calling to auto the SMS OTP
    super.initState();
  }

  void showTopUpScreen() {
    context.pushReplacementNamed('top-up'); // adjust route name
  }

  // @override
  // void didChangeDependencies() {
  //   if (Platform.isAndroid) {
  //     checkForUpdate();
  //   }
  //   super.didChangeDependencies();
  // }

  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   appLifecycleState = state;
  //   if (state == AppLifecycleState.resumed) {}
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //vertically align center
          children: <Widget>[
            SizedBox(
              child: SizedBox(
                  height: 200.h,
                  width: 180.w,
                  child: Image.asset("assets/images/tourist.png")),
            ),
          ],
        ),
      ),
    );
  }
}
