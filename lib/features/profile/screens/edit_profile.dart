import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_button.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/read_sms_otp.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/profile/services/dio_membership.dart';
import 'package:new_piiink/features/profile/services/dio_profile.dart';
import 'package:new_piiink/models/error_res.dart';
import 'package:new_piiink/models/request/edit_profile_req.dart';
import 'package:new_piiink/models/response/common_res.dart';
import 'package:new_piiink/models/response/edit_profile_res.dart';
import 'package:new_piiink/models/response/user_detail_res.dart';

import '../../../common/show_verify_email_bottom_sheet.dart';
import 'package:new_piiink/generated/l10n.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class EditProfile extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final editProfileKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  String? isMobNumChanged; //For checking whether the number is changed or not
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  var reg = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  String? phoneNumberPrefix;
  String? phoneVerifiedBy;
  int? countryId;

  // For filling the edit form
  Future<UserProfileResModel?>? fillUserEditForm;
  Future<UserProfileResModel?> fillEditForm() async {
    UserProfileResModel? userProfileResModel =
        await DioMemberShip().getUserProfile();
    firstNameController.text = userProfileResModel!.data!.results!.firstname!;
    lastNameController.text = userProfileResModel.data!.results!.lastname!;
    mobileNumberController.text =
        userProfileResModel.data!.results!.phoneNumber!;
    isMobNumChanged = userProfileResModel.data!.results!.phoneNumber!;
    phoneNumberPrefix = userProfileResModel.data!.results!.phoneNumberPrefix;
    postalCodeController.text = userProfileResModel.data!.results!.postalCode!;
    emailController.text = userProfileResModel.data!.results!.email!;
    countryId = userProfileResModel.data!.results!.countryId;
    phoneVerifiedBy = userProfileResModel.data!.results!.phoneVerifiedBy;
    return userProfileResModel;
  }

  var isLoading = false;

  @override
  void initState() {
    fillUserEditForm = fillEditForm();
    super.initState();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(S.of(context).deleteAccount),
          content: Text(S.of(context).areYouSureDeleteAccount),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () async {
                // 1. Pop the dialog immediately
                Navigator.of(dialogContext).pop();

                // 2. Start loading on the main screen
                setState(() => isLoading = true);

                // 3. Call the API to delete the member
                var res = await DioProfile().deleteMember();

                if (!mounted) return;

                if (res is CommonResModel &&
                    (res.status?.toLowerCase() == "success" ||
                        res.status == "OK")) {
                  // --- START OF LOGOUT CLEANUP LOGIC ---

                  // Clear specific local data just like the LogOut button does
                  await Pref().removeData("saveToken");
                  await Pref().removeData("issuerType");
                  await Pref().removeData('fcmToken');
                  await Pref().removeData('isTokenSent');
                  await Pref().removeData('notificationsCount');
                  await Pref().removeData("saveUserID");
                  await Pref().removeData("saveCurrency");
                  await Pref().removeData("savePublishableKey");
                  await Pref().removeData("userChosenLocationStateID");
                  await Pref().removeData("userChosenLocationRegionID");

                  // Alternatively, just nuke everything to be safe:
                  await Pref().removeAll();

                  AppVariables.accessToken = null;

                  // Delete Firebase Token
                  try {
                    // ignore: undefined_identifier
                    await FirebaseMessaging.instance.deleteToken();
                  } catch (e) {
                    debugPrint('Firebase token deletion failed: $e');
                  }

                  AppVariables.notificationLabel.value = 0;
                  AppVariables.initNotifications = false;

                  // --- END OF CLEANUP LOGIC ---

                  setState(() => isLoading = false);

                  GlobalSnackBar.showSuccess(context,
                      res.message ?? S.of(context).accountDeletedSuccessfully);

                  // Navigate exactly the way your logout button navigates
                  if (mounted) {
                    context.pushReplacementNamed('bottom-bar',
                        pathParameters: {'page': '4'});
                  }
                } else {
                  setState(() => isLoading = false);
                  GlobalSnackBar.showError(
                      context,
                      (res is ErrorResModel)
                          ? res.message!
                          : S.of(context).errorInEditingProfile);
                }
              },
              child: Text(
                S.of(context).delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).editProfile,
          icon: Icons.arrow_back_ios,
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SingleChildScrollView(
          child: FutureBuilder<UserProfileResModel?>(
              future: fillUserEditForm,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Error1();
                } else if (!snapshot.hasData) {
                  return const CustomAllLoader();
                } else {
                  bool? isEmailVerified =
                      snapshot.data?.data?.results?.isEmailVerified;
                  return Form(
                    key: editProfileKey,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      constraints:
                          const BoxConstraints(maxHeight: double.infinity),
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
                      child: Column(
                        children: [
                          const SizedBox(height: 15),

                          // First Name
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              controller: firstNameController,
                              cursorColor: GlobalColors.appColor,
                              decoration: textInputDecoration2.copyWith(
                                  labelText: S.of(context).firstName),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Last Name
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              controller: lastNameController,
                              cursorColor: GlobalColors.appColor,
                              decoration: textInputDecoration2.copyWith(
                                  labelText: S.of(context).lastName),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Email
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              controller: emailController,
                              style: locationStyle.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: textInputDecoration2.copyWith(
                                labelText: S.of(context).email,
                              ),
                              enabled: isEmailVerified == true ? false : true,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (isEmailVerified == false)
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.2,
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: AutoSizeText(
                                      S.of(context).emailNotVerified,
                                      style: viewAllStyle.copyWith(
                                          color: Colors.red, fontSize: 12.sp),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showVerifyEmailBottomSheet(context,
                                          message: S
                                              .of(context)
                                              .sureVerifyYourEmail);
                                    },
                                    child: AutoSizeText(
                                      S.of(context).verifyNow,
                                      style: viewAllStyle.copyWith(
                                        color: GlobalColors.appColor1,
                                        decoration: TextDecoration.underline,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),

                          // Mobile Number
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 50,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: GlobalColors.paleGray,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Center(
                                  child: AutoSizeText(
                                    phoneNumberPrefix.toString(),
                                    style: locationStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.7,
                                child: TextFormField(
                                  controller: mobileNumberController,
                                  cursorColor: GlobalColors.appColor,
                                  decoration: textInputDecoration2.copyWith(
                                      labelText: S.of(context).mobileNumberA),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Postal Code
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              controller: postalCodeController,
                              cursorColor: GlobalColors.appColor,
                              decoration: textInputDecoration2.copyWith(
                                labelText: S.of(context).postalZipCode,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Update
                          isLoading == true
                              ? const CustomButtonWithCircular()
                              : CustomButton(
                                  text: S.of(context).update,
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (editProfileKey.currentState!
                                        .validate()) {
                                      if (firstNameController.text.isEmpty) {
                                        GlobalSnackBar.valid(context,
                                            S.of(context).pleaseFillFirstName);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                      if (lastNameController.text.isEmpty) {
                                        GlobalSnackBar.valid(context,
                                            S.of(context).pleaseFillLastName);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                      if (!reg.hasMatch(emailController.text) ||
                                          emailController.text.isEmpty) {
                                        GlobalSnackBar.valid(
                                            context,
                                            S
                                                .of(context)
                                                .pleaseFillTheCorrectEmail);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                      if (postalCodeController.text.isEmpty ||
                                          postalCodeController.text.length <
                                              4) {
                                        GlobalSnackBar.valid(
                                            context,
                                            S
                                                .of(context)
                                                .pleaseFillPostalCodeWith4Digits);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }

                                      if (mobileNumberController.text.isEmpty) {
                                        GlobalSnackBar.valid(
                                            context,
                                            S
                                                .of(context)
                                                .pleaseFillThePhoneNumber);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }

                                      var res = isMobNumChanged ==
                                              mobileNumberController.text
                                          ? await DioProfile().editProfile(
                                              editProfileReqModel:
                                                  EditProfileReqModel(
                                                firstname: firstNameController
                                                    .text
                                                    .trim(),
                                                lastname: lastNameController
                                                    .text
                                                    .trim(),
                                                postalCode: postalCodeController
                                                    .text
                                                    .trim(),
                                                phoneNumber:
                                                    mobileNumberController.text
                                                        .trim(),
                                                email:
                                                    emailController.text.trim(),
                                                phoneNumberPrefix:
                                                    phoneNumberPrefix
                                                        .toString(),
                                                phoneVerifiedBy:
                                                    phoneVerifiedBy!,
                                              ),
                                            )
                                          : await DioProfile()
                                              .editProfileNumber(
                                              editProfileReqModelnumber:
                                                  EditProfileReqModelNumber(
                                                firstname: firstNameController
                                                    .text
                                                    .trim(),
                                                lastname: lastNameController
                                                    .text
                                                    .trim(),
                                                postalCode: postalCodeController
                                                    .text
                                                    .trim(),
                                                phoneNumber:
                                                    mobileNumberController.text
                                                        .trim(),
                                                email:
                                                    emailController.text.trim(),
                                                phoneNumberPrefix:
                                                    phoneNumberPrefix
                                                        .toString(),
                                                phoneVerifiedBy:
                                                    phoneVerifiedBy!,
                                                appSign: getAsign,
                                              ),
                                            );

                                      if (!mounted) return;
                                      if (res is EditProfileResModel) {
                                        //checking the status
                                        if (res.status == "update success") {
                                          if (res.smsotpRequired == true) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            context.pushNamed('edit-number',
                                                extra: {
                                                  'mobileNumber':
                                                      mobileNumberController
                                                          .text
                                                          .trim(),
                                                  'email': emailController.text
                                                      .trim(),
                                                  'countryId': countryId!,
                                                  'phoneNumberPrefix':
                                                      phoneNumberPrefix
                                                          .toString()
                                                });
                                          } else {
                                            // Navigator.pop(context);
                                            context.pushReplacementNamed(
                                                'edit-profile');
                                            setState(() {});
                                            GlobalSnackBar.showSuccess(
                                                context,
                                                S
                                                    .of(context)
                                                    .profileUpdatedSuccessfully);
                                          }
                                        }
                                      } else if (res is ErrorResModel) {
                                        GlobalSnackBar.showError(
                                            context,
                                            res.message ??
                                                S.of(context).serverError);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      } else {
                                        GlobalSnackBar.showError(
                                            context,
                                            S
                                                .of(context)
                                                .errorInEditingProfile);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }

                                      // }
                                    }
                                  },
                                ),
                          const SizedBox(height: 20),

// Delete Account Button
                          TextButton(
                            onPressed: () => _showDeleteConfirmation(context),
                            child: Text(
                              S
                                  .of(context)
                                  .deleteAccount, // Ensure this key exists in your ARB/l10n files
                              style: viewAllStyle.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}
