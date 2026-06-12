import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/touristsaver_loading_view.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/read_sms_otp.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/features/profile/services/dio_membership.dart';
import 'package:touristsaver/features/profile/services/dio_profile.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/edit_profile_req.dart';
import 'package:touristsaver/models/response/common_res.dart';
import 'package:touristsaver/models/response/edit_profile_res.dart';
import 'package:touristsaver/models/response/user_detail_res.dart';

import '../../../common/show_verify_email_bottom_sheet.dart';
import 'package:touristsaver/generated/l10n.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

const Color _editProfileNavy = Color(0xFF111C44);
const Color _editProfileMuted = Color(0xFF63708A);
const Color _editProfileBorder = Color(0xFFE5EAF4);
const Color _editProfileSurface = Color(0xFFF7F9FC);

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

  InputDecoration _profileInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _editProfileMuted,
        fontWeight: FontWeight.w700,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF0009FE),
        fontWeight: FontWeight.w800,
      ),
      filled: true,
      fillColor: _editProfileSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _editProfileBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF18C6FF), width: 1.4),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _editProfileBorder),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE86F7F)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE86F7F), width: 1.4),
      ),
    );
  }

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
                  return const TouristSaverLoadingView();
                } else {
                  bool? isEmailVerified =
                      snapshot.data?.data?.results?.isEmailVerified;
                  return Form(
                    key: editProfileKey,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      padding: const EdgeInsets.all(18),
                      constraints:
                          const BoxConstraints(maxHeight: double.infinity),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _editProfileBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            S.of(context).editProfile,
                            style: TextStyle(
                              color: _editProfileNavy,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Keep your TouristSaver membership details up to date.',
                            style: TextStyle(
                              color: _editProfileMuted,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // First Name
                          TextFormField(
                            controller: firstNameController,
                            cursorColor: const Color(0xFF0009FE),
                            style: const TextStyle(
                              color: _editProfileNavy,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _profileInputDecoration(
                                S.of(context).firstName),
                          ),

                          const SizedBox(height: 15),

                          // Last Name
                          TextFormField(
                            controller: lastNameController,
                            cursorColor: const Color(0xFF0009FE),
                            style: const TextStyle(
                              color: _editProfileNavy,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration:
                                _profileInputDecoration(S.of(context).lastName),
                          ),
                          const SizedBox(height: 15),

                          // Email
                          TextFormField(
                            controller: emailController,
                            style: TextStyle(
                              color: isEmailVerified == true
                                  ? _editProfileMuted
                                  : _editProfileNavy,
                              fontWeight: FontWeight.w700,
                            ),
                            cursorColor: const Color(0xFF0009FE),
                            decoration:
                                _profileInputDecoration(S.of(context).email),
                            enabled: isEmailVerified == true ? false : true,
                          ),
                          const SizedBox(height: 6),
                          if (isEmailVerified == false)
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).emailNotVerified,
                                    style: TextStyle(
                                      color: const Color(0xFFE86F7F),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () {
                                    showVerifyEmailBottomSheet(context,
                                        message:
                                            S.of(context).sureVerifyYourEmail);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0009FE)
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      S.of(context).verifyNow,
                                      style: TextStyle(
                                        color: const Color(0xFF0009FE),
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 15),

                          // Mobile Number
                          Row(
                            children: [
                              Container(
                                height: 50,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: _editProfileSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _editProfileBorder),
                                ),
                                child: Center(
                                  child: Text(
                                    phoneNumberPrefix.toString(),
                                    style: const TextStyle(
                                      color: _editProfileNavy,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: mobileNumberController,
                                  cursorColor: const Color(0xFF0009FE),
                                  style: const TextStyle(
                                    color: _editProfileNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: _profileInputDecoration(
                                      S.of(context).mobileNumberA),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Postal Code
                          TextFormField(
                            controller: postalCodeController,
                            cursorColor: const Color(0xFF0009FE),
                            style: const TextStyle(
                              color: _editProfileNavy,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _profileInputDecoration(
                              S.of(context).postalZipCode,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Update
                          _EditProfileGradientButton(
                            text: S.of(context).update,
                            isLoading: isLoading,
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (editProfileKey.currentState!.validate()) {
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
                                  GlobalSnackBar.valid(context,
                                      S.of(context).pleaseFillTheCorrectEmail);
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }
                                if (postalCodeController.text.isEmpty ||
                                    postalCodeController.text.length < 4) {
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
                                  GlobalSnackBar.valid(context,
                                      S.of(context).pleaseFillThePhoneNumber);
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
                                          firstname:
                                              firstNameController.text.trim(),
                                          lastname:
                                              lastNameController.text.trim(),
                                          postalCode:
                                              postalCodeController.text.trim(),
                                          phoneNumber: mobileNumberController
                                              .text
                                              .trim(),
                                          email: emailController.text.trim(),
                                          phoneNumberPrefix:
                                              phoneNumberPrefix.toString(),
                                          phoneVerifiedBy: phoneVerifiedBy!,
                                        ),
                                      )
                                    : await DioProfile().editProfileNumber(
                                        editProfileReqModelnumber:
                                            EditProfileReqModelNumber(
                                          firstname:
                                              firstNameController.text.trim(),
                                          lastname:
                                              lastNameController.text.trim(),
                                          postalCode:
                                              postalCodeController.text.trim(),
                                          phoneNumber: mobileNumberController
                                              .text
                                              .trim(),
                                          email: emailController.text.trim(),
                                          phoneNumberPrefix:
                                              phoneNumberPrefix.toString(),
                                          phoneVerifiedBy: phoneVerifiedBy!,
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
                                      context.pushNamed('edit-number', extra: {
                                        'mobileNumber':
                                            mobileNumberController.text.trim(),
                                        'email': emailController.text.trim(),
                                        'countryId': countryId!,
                                        'phoneNumberPrefix':
                                            phoneNumberPrefix.toString()
                                      });
                                    } else {
                                      // Navigator.pop(context);
                                      context
                                          .pushReplacementNamed('edit-profile');
                                      setState(() {});
                                      GlobalSnackBar.showSuccess(
                                          context,
                                          S
                                              .of(context)
                                              .profileUpdatedSuccessfully);
                                    }
                                  }
                                } else if (res is ErrorResModel) {
                                  GlobalSnackBar.showError(context,
                                      res.message ?? S.of(context).serverError);
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                } else {
                                  GlobalSnackBar.showError(context,
                                      S.of(context).errorInEditingProfile);
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

                          Center(
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFE86F7F),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _showDeleteConfirmation(context),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 17,
                              ),
                              label: Text(
                                S.of(context).deleteAccount,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                ),
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

class _EditProfileGradientButton extends StatelessWidget {
  const _EditProfileGradientButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isLoading ? null : onPressed,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0009FE),
                Color(0xFF18C6FF),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0009FE).withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
