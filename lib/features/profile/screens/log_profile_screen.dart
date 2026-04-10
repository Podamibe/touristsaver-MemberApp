import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_piiink/common/services/dio_common.dart';
import 'package:new_piiink/common/utils.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_button.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/connectivity/cubit/internet_cubit.dart';
import 'package:new_piiink/features/profile/bloc/user_profile_blocs.dart';
import 'package:new_piiink/features/profile/bloc/user_profile_events.dart';
import 'package:new_piiink/features/profile/bloc/user_profile_states.dart';
import 'package:new_piiink/features/profile/services/dio_membership.dart';
import 'package:new_piiink/models/request/change_password_req.dart';
import 'package:new_piiink/models/response/change_password_res.dart';
import 'package:new_piiink/models/response/piiink_info_res.dart';
import 'package:new_piiink/models/response/user_delete_res.dart';
import 'package:new_piiink/models/response/user_detail_res.dart';
import 'package:new_piiink/splash_screen.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';

import '../../../common/app_variables.dart';
import '../../../common/services/device_info.dart';
import '../../../common/show_verify_email_bottom_sheet.dart';
import '../../../constants/helper.dart';
import '../../../constants/url_end_point.dart';
import '../../connectivity/screens/connectivity.dart';

import 'package:new_piiink/generated/l10n.dart';

class LogProfileScreen extends StatefulWidget {
  static const String routeName = '/log-profile';
  const LogProfileScreen({super.key});

  @override
  State<LogProfileScreen> createState() => _LogProfileScreenState();
}

class _LogProfileScreenState extends State<LogProfileScreen> {
  //For Login using FingerPrint (BioMetric)
  var localAuth = LocalAuthentication();

  final changeKey = GlobalKey<FormState>();
  final profileRefreshKey = GlobalKey<RefreshIndicatorState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  List<String> additionalList = [];
  buildAdditionalList() {
    additionalList.addAll([
      // S.of(context).charity,
      S.of(context).changeCountry,
      S.of(context).changePassword,
      S.of(context).editProfile,
      // S.of(context).rewards,
      S.of(context).recommendNewMerchant,
      S.of(context).referAFriend,
      S.of(context).biometrics,
      S.of(context).about,
      S.of(context).termsConditions,
    ]);
  }

  bool? hideRecommendOption;
  bool? hideRemoveAccountButton;
  String? hideRewardsOption;

  bool isHidden = true;
  bool isHidden1 = true;
  bool isHidden2 = true;

  Future<void> getPiiinkInfo() async {
    PiiinkInfoResModel? piiinkInfoResModel = await DioCommon().piiinkInfo();
    if (!mounted) return;
    setState(() {
      hideRecommendOption = piiinkInfoResModel?.data?.hideReferredMerchantInApp;
      hideRemoveAccountButton = piiinkInfoResModel?.data?.hideRemoveAccount;
      if (hideRecommendOption == true) {
        additionalList.remove(S.of(context).recommendNewMerchant);
        // additionalList.insert(3, recommend);
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      buildAdditionalList();
      // hideRewardsOption = await Pref().readData(key: issuerType);

      localAuth.isDeviceSupported().then((bool isSupported) {
        if (!isSupported) {
          additionalList.remove(S.of(context).biometrics);
        }
      });
      // log(hideRewardsOption.toString());
      // if (hideRewardsOption != 'company') {
      //   if (!mounted) return;
      //   additionalList.remove(S.of(context).rewards);
      // }
    });
    getPiiinkInfo();
    super.initState();
  }

  @override
  void dispose() {
    ConnectivityCubit().close();
    super.dispose();
  }

  final DioMemberShip _dioMembership = DioMemberShip();
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: profileRefreshKey,
      color: GlobalColors.appColor,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
        getPiiinkInfo();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: FutureBuilder<bool>(
            future: checkWalletBalance(), // 👈 call the async function
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                // show placeholder or loader while fetching
                return const SizedBox.shrink();
              }

              final hasBalance = snapshot.data ?? false;

              return CustomAppBar(
                text: S.of(context).profile,
                icon: hasBalance ? null : Icons.arrow_back_ios,
                onPressed: () => context.pop(),
              );
            },
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
            builder: (context, state) {
              return ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //MemberShip
                        (state == ConnectivityState.loading)
                            ? const NoInternetLoader()
                            : (state == ConnectivityState.disconnected)
                                ? const NoInternetWidget()
                                : (state == ConnectivityState.connected)
                                    ? memberShipBox()
                                    : const SizedBox(),

                        profileScreenList(),

                        if (hideRemoveAccountButton == false)
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              Center(
                                child: CustomButton1(
                                  text: S.of(context).removeAccount,
                                  onPressed: () {
                                    removeButton();
                                  },
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        // Logout Button
                        logOut(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  //Membership
  memberShipBox() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.05,
      // height: MediaQuery.of(context).size.height / 1.4,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
      //User Profile
      child: Container(
        width: MediaQuery.of(context).size.width / 1.15,
        // height: MediaQuery.of(context).size.height / 2.9,
        // height: MediaQuery.of(context).size.height / 4.0,
        decoration: const BoxDecoration(
          color: GlobalColors.paleGray,
        ),
        child: OutlineGradientButton(
          strokeWidth: 3,
          radius: const Radius.circular(5.0),
          gradient: const LinearGradient(
            colors: [GlobalColors.appColor, GlobalColors.appColor1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          child: BlocProvider(
            lazy: false,
            create: (context) =>
                UserProfileBloc(_dioMembership)..add(LoadUserProfileEvent()),
            child: BlocBuilder<UserProfileBloc, UserProfileState>(
                builder: (context, state) {
              if (state is UserProfileLoadingState) {
                return const CustomAllLoader1();
              } else if (state is UserProfileLoadedState) {
                UserProfileResModel userProfile = state.userProfile;

                return profileSection(userProfile);
              } else if (state is UserProfileErrorState) {
                return memError();
              } else {
                return const SizedBox();
              }
            }),
          ),
        ),
      ),
    );
  }

  // Profile Section
  profileSection(UserProfileResModel userProfile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(height: 5),

        // Country
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Image.asset(
                "assets/images/globe.png",
                height: 30,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: AutoSizeText(
                userProfile.data!.results!.country!.countryName!,
                style: textStyle15.copyWith(fontSize: 18.sp),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // Card Number
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Image.asset(
                "assets/images/credit-card.png",
                height: 23,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                userProfile.data!.results!.uniqueMemberCode ??
                    S.of(context).noMemberCode,
                style: textStyle15.copyWith(fontSize: 18.sp),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // User Name
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Image.asset(
                "assets/images/profile.png",
                height: 30,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: AutoSizeText(
                '${userProfile.data!.results!.firstname!} ${userProfile.data!.results!.lastname!}',
                style: textStyle15.copyWith(fontSize: 18.sp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Mobile Number
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Image.asset(
                "assets/images/mobile.png",
                height: 30,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: AutoSizeText(
                '${userProfile.data!.results!.phoneNumberPrefix} ${userProfile.data!.results!.phoneNumber!}',
                style: textStyle15.copyWith(fontSize: 18.sp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Email
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Image.asset("assets/images/mail.png", height: 25),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: AutoSizeText(
                userProfile.data!.results!.email!,
                maxLines: 1,
                style: textStyle15.copyWith(fontSize: 18.sp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Issuer Code
        Row(
          children: [
            Expanded(
              child: Center(
                child: AutoSizeText(
                  "Issuer Code : ${userProfile.data!.issuerCode}",
                  maxLines: 1,
                  style: textStyle15.copyWith(fontSize: 18.sp),
                ),
              ),
            ),
          ],
        ),
        if (userProfile.data?.results?.isEmailVerified == false)
          Padding(
            padding: const EdgeInsets.only(left: 80, top: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  showVerifyEmailBottomSheet(context);
                },
                child: AutoSizeText(
                  S.of(context).verifyEmail,
                  style: notiHeaderTextStyle.copyWith(
                    fontSize: 16.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 5),
      ],
    );
  }

  //Error
  memError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: SizedBox(
              height: 100.h,
              width: 120.w,
              child: Image.asset("assets/images/oops.png")),
        ),
        const SizedBox(height: 10),
        AutoSizeText(
          S.of(context).oops,
          style: topicStyle,
        ),
        const SizedBox(height: 10),
        AutoSizeText(
          S.of(context).somethingWentWrong,
          style: topicStyle,
        )
      ],
    );
  }

  // Profile Screen List
  profileScreenList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
      itemCount: additionalList.length,
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: () {
            additionalList[index] == S.of(context).charity
                ? context.pushNamed('charity-list')
                : additionalList[index] == S.of(context).changeCountry
                    ? context.pushNamed('change-country')
                    : additionalList[index] == S.of(context).changePassword
                        ? changePopUpPassword()
                        : additionalList[index] == S.of(context).editProfile
                            ? context.pushNamed('edit-profile')
                            :
                            //  additionalList[index] == S.of(context).rewards
                            //     ? context.pushNamed('rewards-screen')
                            //     :
                            additionalList[index] ==
                                    S.of(context).recommendNewMerchant
                                ? context.pushNamed('recommend')
                                : additionalList[index] ==
                                        S.of(context).referAFriend
                                    ? context.pushNamed('memberReferral')
                                    : additionalList[index] ==
                                            S.of(context).biometrics
                                        ? context.pushNamed('settings-screen')
                                        : additionalList[index] ==
                                                S.of(context).termsConditions
                                            ? context
                                                .pushNamed('terms-condition')
                                            : context.pushNamed('about-screen');
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 55,
            child: ListTile(
              tileColor: GlobalColors.appWhiteBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              title: Padding(
                padding: const EdgeInsets.only(top: 1.0),
                // Text Name
                child: AutoSizeText(
                  additionalList[index],
                  style: profileListStyle,
                ),
              ),
              // Arrow
              trailing: Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 25,
                  color: GlobalColors.gray.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Change Password PopUp
  changePopUpPassword() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    setState(() {
      isHidden = true;
      isHidden1 = true;
      isHidden2 = true;
    });
    bool isLoading = false;
    //bool for tracking the pop up
    bool trackDialog = false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Center(
              child: SingleChildScrollView(
                child: AlertDialog(
                  content: Text(
                    S.of(context).changePassword,
                    textAlign: TextAlign.center,
                    style: topicStyle,
                  ),
                  actions: [
                    StatefulBuilder(
                      builder: (context, stateMode) {
                        return Form(
                          key: changeKey,
                          child: Column(
                            children: [
                              // Recent Password
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.2,
                                child: TextFormField(
                                  controller: currentPasswordController,
                                  cursorColor: GlobalColors.appColor,
                                  decoration: textInputDecoration1.copyWith(
                                    hintText: S.of(context).currentPassword,
                                    suffix: GestureDetector(
                                      onTap: () {
                                        stateMode(() {
                                          isHidden = !isHidden;
                                        });
                                      },
                                      child: isHidden
                                          ? const Icon(
                                              Icons.visibility_off,
                                              size: 20,
                                            )
                                          : const Icon(
                                              Icons.visibility,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                  obscureText: isHidden,
                                  validator: (currentPassword) {
                                    if (currentPassword == null ||
                                        currentPassword.isEmpty) {
                                      stateMode(() {
                                        isLoading = false;
                                      });
                                      return S
                                          .of(context)
                                          .pleaseEnterCurrentPassword;
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 15),

                              // New Password
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.2,
                                child: TextFormField(
                                  controller: newPasswordController,
                                  cursorColor: GlobalColors.appColor,
                                  decoration: textInputDecoration1.copyWith(
                                    hintText: S.of(context).newPassword,
                                    suffix: GestureDetector(
                                      onTap: () {
                                        stateMode(() {
                                          isHidden1 = !isHidden1;
                                        });
                                      },
                                      child: isHidden1
                                          ? const Icon(
                                              Icons.visibility_off,
                                              size: 20,
                                            )
                                          : const Icon(
                                              Icons.visibility,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                  obscureText: isHidden1,
                                  validator: (newPassword) {
                                    if (newPassword == null ||
                                        newPassword.isEmpty ||
                                        newPassword ==
                                            currentPasswordController.text
                                                .trim()) {
                                      stateMode(() {
                                        isLoading = false;
                                      });
                                      return newPassword ==
                                              currentPasswordController.text
                                                  .trim()
                                          ? S.of(context).passwordsAreSame
                                          : S.of(context).enterNewPassword;
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Confirm New Password
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.2,
                                child: TextFormField(
                                  controller: confirmNewPasswordController,
                                  cursorColor: GlobalColors.appColor,
                                  decoration: textInputDecoration1.copyWith(
                                    hintText: S.of(context).confirmPassword,
                                    suffix: GestureDetector(
                                      onTap: () {
                                        stateMode(() {
                                          isHidden2 = !isHidden2;
                                        });
                                      },
                                      child: isHidden2
                                          ? const Icon(
                                              Icons.visibility_off,
                                              size: 20,
                                            )
                                          : const Icon(
                                              Icons.visibility,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                  obscureText: isHidden2,
                                  validator: (confirmPassword) {
                                    if (confirmPassword == null ||
                                        confirmPassword.isEmpty ||
                                        confirmPassword !=
                                            newPasswordController.text.trim() ||
                                        confirmPassword ==
                                            currentPasswordController.text
                                                .trim()) {
                                      stateMode(() {
                                        isLoading = false;
                                      });
                                      return confirmPassword ==
                                              currentPasswordController.text
                                                  .trim()
                                          ? S.of(context).passwordsAreSame
                                          : S.of(context).passwordNoMatch;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Yes Button
                              isLoading == true
                                  ? const CustomButtonWithCircular()
                                  : CustomButton(
                                      onPressed: () async {
                                        stateMode(() {
                                          isLoading = true;
                                        });
                                        if (changeKey.currentState!
                                            .validate()) {
                                          var res =
                                              await DioMemberShip().changePass(
                                            changePasswordReqModel:
                                                ChangePasswordReqModel(
                                              currentPassword:
                                                  currentPasswordController.text
                                                      .trim(),
                                              newPassword: newPasswordController
                                                  .text
                                                  .trim(),
                                              newConfirmPassword:
                                                  confirmNewPasswordController
                                                      .text
                                                      .trim(),
                                            ),
                                          );
                                          if (!mounted) return;
                                          if (res is ChangePasswordResModel) {
                                            if (res.status == 'Success') {
                                              stateMode(() {
                                                Pref().writeData(
                                                    key: 'savePassword',
                                                    value: newPasswordController
                                                        .text
                                                        .trim());
                                                isLoading = false;
                                                trackDialog = true;
                                              });
                                              context.pop();
                                            }
                                          } else {
                                            GlobalSnackBar.showError(
                                                context,
                                                S
                                                    .of(context)
                                                    .currentPasswordDoesNotMatch);
                                            stateMode(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      },
                                      text: S.of(context).save,
                                    ),
                              const SizedBox(height: 15),
                              // No Button
                              CustomButton1(
                                onPressed: () {
                                  context.pop();
                                },
                                text: S.of(context).cancel,
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )).then((value) => trackDialog == true
        ? GlobalSnackBar.showSuccess(
            context, S.of(context).passwordChangedSuccessfully)
        : null);
  }

// Logout Button
  logOut() {
    return Center(
      child: CustomButton(
        text: S.of(context).logOut,
        onPressed: () async {
          return showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              // Use a distinct context for the dialog
              bool logOutConfirmed = false;
              return AlertDialog(
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).areYouSureYouWantToLogOut,
                        textAlign: TextAlign.center,
                        style: topicStyle,
                      ),
                      const SizedBox(height: 15),
                      // Yes Button
                      logOutConfirmed == true
                          ? const CustomButtonWithCircular()
                          : CustomButton(
                              onPressed: () async {
                                // 1. Show loading state immediately
                                setState(() {
                                  logOutConfirmed = true;
                                });

                                bool apiSuccess = false;
                                try {
                                  // Get deviceId before removing any local tokens
                                  String deviceId =
                                      AppVariables.deviceId.isNotEmpty
                                          ? AppVariables.deviceId
                                          : await getDeviceId();

                                  // API call to delete device ID for notifications
                                  var response = await getClient().then(
                                    (dio) => dio.delete(
                                      deleteDeviceIdOnLogOut
                                          .format(params: [deviceId]),
                                    ),
                                  );

                                  if (response.data != null &&
                                      response.data['status'] == "Success") {
                                    apiSuccess = true;
                                  }
                                  // If API fails or status is not 'Success', it falls to the 'finally' block
                                } catch (e) {
                                  // This catch block handles DioErrors (network issues, 4xx/5xx status codes)
                                  debugPrint(
                                      'Error during device ID deletion: $e');
                                  // Do not set apiSuccess to true here.
                                }

                                // --- Common Logout Logic (Always runs, regardless of API success) ---
                                // The following steps clear local data and navigate the user away.

                                // 2. Clear Local Data (Essential for a logout)
                                await Pref().removeData(saveToken);
                                await Pref().removeData(issuerType);
                                await Pref().removeData('fcmToken');
                                await Pref().removeData('isTokenSent');
                                await Pref().removeData('notificationsCount');
                                await Pref().removeData(saveUserID);
                                await Pref().removeData(saveCurrency);
                                await Pref().removeData(savePublishableKey);
                                await Pref()
                                    .removeData(userChosenLocationStateID);
                                await Pref()
                                    .removeData(userChosenLocationRegionID);
                                AppVariables.accessToken = null;

                                // 3. Delete Firebase Token (Always try to clear it locally)
                                try {
                                  await FirebaseMessaging.instance
                                      .deleteToken();
                                } catch (e) {
                                  debugPrint(
                                      'Firebase token deletion failed: $e');
                                }

                                AppVariables.notificationLabel.value = 0;
                                AppVariables.initNotifications = false;

                                if (!mounted) return;

                                // 4. Dismiss Dialog and Navigate (Crucial Fixes)

                                // Dismiss the dialog immediately after cleaning up and before navigating
                                // Use the dialogContext for this
                                Navigator.of(dialogContext).pop();

                                // Navigate to the login/home screen
                                context.pushReplacementNamed('bottom-bar',
                                    pathParameters: {'page': '4'});

                                // If the API succeeded, you can show a success snackbar if needed.
                                if (apiSuccess) {
                                  // GlobalSnackBar.showSuccess(dialogContext, 'Logged out successfully');
                                } else {
                                  // If the API failed, we still logged out locally, so only log the error.
                                  // Optionally, show a generic message that logout succeeded locally.
                                }
                              },
                              text: S.of(context).yes,
                            ),
                      const SizedBox(height: 10),
                      CustomButton1(
                        onPressed: () {
                          // Correctly pop the dialog
                          Navigator.of(context).pop();
                        },
                        text: S.of(context).cancel,
                      ),
                    ],
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }

  // Remove Button
  removeButton() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        bool removeAccountConfirmed = false;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).areYouSureYouWantToRemoveYourAccount,
                  textAlign: TextAlign.center,
                  style: topicStyle,
                ),
                const SizedBox(height: 15),
                // Yes Button
                removeAccountConfirmed == true
                    ? const CustomButtonWithCircular()
                    : CustomButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              removeAccountConfirmed = true;
                            });
                            var deleteRes = await DioCommon().userDeletion();
                            if (deleteRes is UserDeleteResModel) {
                              if (!mounted) return;
                              if (deleteRes.status == 'success') {
                                await Pref().removeData(saveToken);
                                await Pref().removeData(issuerType);
                                await Pref().removeData('fcmToken');
                                await Pref().removeData('isTokenSent');
                                await Pref().removeData('notificationsCount');
                                await Pref().removeData(saveUserID);
                                await Pref().removeData(saveCurrency);
                                await Pref().removeData(savePublishableKey);
                                await Pref()
                                    .removeData(userChosenLocationStateID);
                                await Pref()
                                    .removeData(userChosenLocationRegionID);
                                AppVariables.accessToken = null;

                                if (!mounted) return;
                                GlobalSnackBar.showSuccess(
                                    context, deleteRes.message!);
                              }
                            }
                            // else {
                            //   if (!mounted) return;
                            //   GlobalSnackBar.showError(
                            //       context, "Couldn't delete the account!");
                            // }
                          } catch (e) {
                            // GlobalSnackBar.showError(
                            //     context, "Couldn't delete the account!");
                          }
                          try {
                            await FirebaseMessaging.instance.deleteToken();
                          } catch (e) {
                            log(e.toString());
                          }
                          AppVariables.notificationLabel.value = 0;
                          AppVariables.initNotifications = false;
                          if (!mounted) return;
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
                  text: S.of(context).cancel,
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
