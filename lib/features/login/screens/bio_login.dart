import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../../common/app_variables.dart';

import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../constants/global_colors.dart';
import '../../../constants/pref.dart';
import '../../../constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class SettingScreen extends StatefulWidget {
  static const String routeName = '/settings-screen';
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  //For Login using FingerPrint (BioMetric)
  var localAuth = LocalAuthentication();
  bool isFingerPrintLogin = AppVariables.isLocalAuthEnabled == false ||
          AppVariables.isLocalAuthEnabled == null
      ? false
      : true;

  toggleSwitch(bool value) async {
    // final List<BiometricType> availableBiometrics =
    //     await localAuth.getAvailableBiometrics();
    if (isFingerPrintLogin == false) {
      //checking if biometric auth is supported
      if (AppVariables.isLocalAuthEnabled == false ||
          AppVariables.isLocalAuthEnabled == null &&
              await localAuth.canCheckBiometrics) {
        //Ask for enable biometric auth
        if (!mounted) return;
        // showModalBottomSheet(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return EnableLocalAuthModalBottomSheet(action: onEnableLocalAuth);
        //     });
        // if (availableBiometrics.contains(BiometricType.strong) ||
        //     availableBiometrics.contains(BiometricType.face)) {
        bool didAuthenticate = await localAuth.authenticate(
            localizedReason:
                S.of(context).linkYourFingerprintFaceForFasterLogin,
            options: const AuthenticationOptions(
                useErrorDialogs: true, biometricOnly: true, stickyAuth: true),
            authMessages: [
              AndroidAuthMessages(
                  biometricHint: '',
                  signInTitle: S.of(context).biometricAuthentication,
                  cancelButton: S.of(context).noThanks),
              IOSAuthMessages(
                cancelButton: S.of(context).noThanks,
              )
            ]);

        if (didAuthenticate) {
          onEnableLocalAuth();
        }
      } else {
        //If there is no fingerprint function available in the device.
        if (!mounted) return;
        GlobalSnackBar.showError(context, S.of(context).noBiometricFunction);
        setState(() {
          isFingerPrintLogin = false;
        });
      }
    } else {
      //If user disable the fingerprint auth
      if (AppVariables.isLocalAuthEnabled == true ||
          AppVariables.isLocalAuthEnabled != null &&
              await localAuth.canCheckBiometrics) {
        if (!mounted) return;
        bool didAuthenticate = await localAuth.authenticate(
            localizedReason: S.of(context).doYouWantToDisableBiometricLogin,
            options: const AuthenticationOptions(
                useErrorDialogs: true, biometricOnly: true, stickyAuth: true),
            authMessages: [
              AndroidAuthMessages(
                  biometricHint: '',
                  signInTitle: S.of(context).biometricAuthentication,
                  cancelButton: S.of(context).noThanks),
              IOSAuthMessages(cancelButton: S.of(context).noThanks)
            ]);
        if (didAuthenticate) {
          onDisableLocalAuth();
        }
      }
    }
    //   }
  }

  //Method associated to UI Button in modalBottomSheet
  //It enables local_auth and saves data into storage
  onEnableLocalAuth() async {
    //save
    await Pref().setBool(key: 'saveLocalAuth', value: true);
    setState(() {
      isFingerPrintLogin = true;
    });
    AppVariables.isLocalAuthEnabled =
        await Pref().readBool(key: 'saveLocalAuth');
    if (!mounted) return;
    GlobalSnackBar.showSuccess(
        context, S.of(context).biometricAuthenticationEnabledSuccessfully);
  }

  onDisableLocalAuth() async {
    //save
    await Pref().setBool(key: 'saveLocalAuth', value: false);
    setState(() {
      isFingerPrintLogin = false;
    });
    AppVariables.isLocalAuthEnabled =
        await Pref().readBool(key: 'saveLocalAuth');
    if (!mounted) return;
    GlobalSnackBar.showSuccess(
        context, S.of(context).biometricAuthenticationDisabledSuccessfully);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            text: S.of(context).biometrics,
            // 'Biometrics',
            icon: Icons.arrow_back_ios,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                color: GlobalColors.appWhiteBackgroundColor,
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).useBiometrics,
                    style: buttonText.copyWith(color: Colors.black),
                  ),
                  Switch(
                    onChanged: toggleSwitch,
                    value: isFingerPrintLogin,
                    activeThumbColor: GlobalColors.appColor1,
                    activeTrackColor: Colors.grey.withValues(alpha: 0.6),
                    inactiveThumbColor: GlobalColors.gray,
                    inactiveTrackColor: Colors.grey.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
