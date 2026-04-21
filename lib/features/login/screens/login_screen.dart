// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:new_piiink/common/services/dio_common.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_button.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/common/widgets/dropdown_button_widget.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/constants/env.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/initialize_stripe.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/constants/read_sms_otp.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/connectivity/cubit/internet_cubit.dart';
import 'package:new_piiink/features/location/bloc/location_all_blocs.dart';
import 'package:new_piiink/features/location/bloc/location_all_events.dart';
import 'package:new_piiink/features/location/bloc/location_all_states.dart';
import 'package:new_piiink/features/location/services/dio_location.dart';
import 'package:new_piiink/features/login/services/dio_login.dart';
import 'package:new_piiink/features/profile/services/dio_membership.dart';
import 'package:new_piiink/models/error_res.dart';
import 'package:new_piiink/models/request/login_req.dart';
import 'package:new_piiink/models/request/reset_password_req.dart';
import 'package:new_piiink/models/response/common_res.dart';
import 'package:new_piiink/models/response/forgot_password_res.dart';
import 'package:new_piiink/models/response/location_get_all.dart';
import 'package:new_piiink/models/response/login_res.dart';
import 'package:new_piiink/models/response/stripe_key_res.dart';
import 'package:new_piiink/models/response/user_detail_res.dart';
import 'package:new_piiink/splash_screen.dart';

import '../../../common/app_variables.dart';
import '../../../models/response/country_wise_prefix_res_model.dart'
    as phone_pre;
import '../../connectivity/screens/connectivity.dart';
import '../../connectivity/screens/connectivity_screen.dart';
import 'package:new_piiink/generated/l10n.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController numController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isHidden = true;
  final TextEditingController forgotEmailnumController =
      TextEditingController();
  String successMessage = '';

  // Reset Password
  final resetKey = GlobalKey<FormState>();
  final TextEditingController countrySearchController = TextEditingController();
  final TextEditingController resetOTPController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  final TextEditingController phonePrefixSearchController =
      TextEditingController();
  bool _isHidden1 = true;
  bool _isHidden2 = true;

  // For dropDown of selecting country
  String? selectedCountry;
  int? selectedCountryID;
  String? selectedPhonePrefix;

  // For the Loading part
  var isLoading = false; //For Login screen
  var isLoadingF = false; //For Forgot Password
  var isLoadingR = false; //For Reset Password

  final ValueNotifier<String> _timerState = ValueNotifier<String>('');

  //For biometric authentication
  var localAuth = LocalAuthentication();

  //Reading the values for biometric authentication
  Future<void> readFromSharedPref() async {
    AppVariables.isLocalAuthEnabled =
        await Pref().readBool(key: 'saveLocalAuth') ?? false;

    if (AppVariables.isLocalAuthEnabled == true) {
      bool didAuthenticate = await localAuth.authenticate(
          localizedReason: S.of(context).pleaseAuthenticateToSignIn,
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
        numController.text = await Pref().readData(key: 'saveUsername') ?? '';
        passwordController.text =
            await Pref().readData(key: 'savePassword') ?? '';
        selectedPhonePrefix = await Pref().readData(key: 'phonePrefix');
        selectedCountryID =
            int.parse(await Pref().readData(key: saveCountryID));
        selectedCountry = await Pref().readData(key: userChosenLocationName);
        //Calling onFromSubmit for a login process
        onLoginSubmit();
      }
    } else {
      numController.text = '';
      passwordController.text = '';
      selectedCountryID = null;
    }
  }

//For finger Print login
  checkSavedCredentials(String token) async {
    String? savedUsername = await Pref().readData(key: 'saveUsername');
    if (numController.text.trim() != savedUsername) {
      await Pref().setBool(key: 'saveLocalAuth', value: false);
      AppVariables.isLocalAuthEnabled = false;
    }
    await Pref().writeData(key: saveToken, value: token).then((value) async {
      AppVariables.accessToken = await Pref().readData(key: saveToken);
    });
    await Pref()
        .writeData(key: 'saveUsername', value: numController.text.trim());
    await Pref()
        .writeData(key: 'savePassword', value: passwordController.text.trim());
    await Pref().writeData(key: 'phonePrefix', value: selectedPhonePrefix!);
  }

  @override
  void dispose() {
    ConnectivityCubit().close();
    super.dispose();
  }

  void showTopUpScreen() {
    context.pushReplacementNamed('top-up'); // adjust route name
  }

  void showPaidFreeScreen() {
    context.pushReplacementNamed('paid-free'); // adjust route name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.appWhiteBackgroundColor, // Clean background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).logIn,
          // icon: Icons.arrow_back_ios,
          // onPressed: () {
          //   context.pop();
          // },
        ),
      ),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
          if (state == ConnectivityState.loading) {
            return const NoInternetLoader();
          } else if (state == ConnectivityState.disconnected) {
            return const NoConnectivityScreen();
          } else if (state == ConnectivityState.connected) {
            return Align(
                alignment: Alignment.topCenter,
                // Centered on screen
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: BlocProvider(
                    lazy: false,
                    create: (context) => LocationAllBloc(
                        RepositoryProvider.of<DioLocation>(context))
                      ..add(LoadLocationAllEvent()),

                    child: BlocBuilder<LocationAllBloc, LocationAllState>(
                      builder: (context, locationState) {
                        // Loading State
                        if (locationState is LocationAllLoadingState) {
                          return const CustomAllLoader();
                        }
                        // Loaded State
                        else if (locationState is LocationAllLoadedState) {
                          LocationGetAllResModel locationList =
                              locationState.locationGetAll;
                          phone_pre.CountryWisePrefixResModel phonePrefixList =
                              locationState.countryWisePrefixResModel;

                          return Container(
                            width: MediaQuery.of(context).size.width *
                                0.9, // 90% of screen width
                            padding: EdgeInsets.symmetric(
                                vertical: 20.h, horizontal: 20.w),
                            margin: EdgeInsets.only(top: 50.h, bottom: 40.h),
                            decoration: BoxDecoration(
                                color: Colors.white, // Pure white card
                                borderRadius: BorderRadius.circular(
                                    20.r), // Smooth rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: GlobalColors.appColor
                                        .withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(
                                        0, 5), // Soft floating shadow
                                  )
                                ]),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min, // Wrap content tightly
                              children: [
                                // --- App Logo ---
                                SizedBox(
                                  height: 80.h,
                                  child: Image.asset(
                                      "assets/images/tourist.png",
                                      fit: BoxFit.contain),
                                ),
                                SizedBox(height: 15.h),

                                // --- Welcome Text ---
                                // Text(
                                //   "Welcome Back!",
                                //   style: TextStyle(
                                //     fontSize: 24.sp,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.black87,
                                //   ),
                                // ),
                                SizedBox(height: 5.h),
                                Text(
                                  "Sign in to continue",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 30.h),

                                // --- Country Dropdown ---
                                DropdownButtonWidget(
                                  label: S.of(context).selectCountryA,
                                  searchController: countrySearchController,
                                  lPadding: 15,
                                  items: locationList.data!.map((e) {
                                    return DropdownMenuItem(
                                      value: e.countryName,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: AutoSizeText(
                                          '(${e.phonePrefix}) ${e.countryName!}',
                                          style: dopdownTextStyle,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newVal) async {
                                    setState(() {
                                      selectedCountry = newVal as String;
                                    });
                                    final locationID = locationList.data!
                                        .firstWhere((element) =>
                                            element.countryName ==
                                            selectedCountry);
                                    selectedPhonePrefix =
                                        locationID.phonePrefix;
                                    selectedCountryID = locationID.id!;
                                  },
                                  value: selectedCountry,
                                ),
                                SizedBox(height: 20.h),

                                // --- Mobile Number ---
                                TextFormField(
                                  controller: numController,
                                  cursorColor: GlobalColors.appColor,
                                  keyboardType: TextInputType.number,
                                  decoration: textInputDecoration1.copyWith(
                                      hintText: S.of(context).mobileNumberA),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]*'))
                                  ],
                                ),
                                SizedBox(height: 20.h),

                                // --- Password ---
                                IgnorePointer(
                                  ignoring: isLoading,
                                  child: TextFormField(
                                    controller: passwordController,
                                    cursorColor: GlobalColors.appColor,
                                    decoration: textInputDecoration1.copyWith(
                                      hintText: S.of(context).passwordA,
                                      suffix: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isHidden = !_isHidden;
                                          });
                                        },
                                        child: _isHidden
                                            ? Icon(
                                                Icons.visibility_off,
                                                size: 20,
                                                color: Colors.grey.shade600,
                                              )
                                            : Icon(
                                                Icons.visibility,
                                                size: 20,
                                                color: GlobalColors.appColor,
                                              ),
                                      ),
                                    ),
                                    obscureText: isLoading == true || _isHidden,
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                // --- Forgot Password ---
                                InkWell(
                                  onTap: () async {
                                    forgotEmailnumController.clear();
                                    forgotPopUp(locationList.data ?? [],
                                        phonePrefixList.data ?? []);
                                  },
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: 5.w, bottom: 20.h),
                                      child: AutoSizeText(
                                        S.of(context).forgotPassword,
                                        style: textStyle15h.copyWith(
                                          decoration: TextDecoration.underline,
                                          color: GlobalColors
                                              .appColor, // Colored link
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // --- Login Button ---
                                isLoading == true
                                    ? const CustomButtonWithCircular()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: CustomButton(
                                                text: S.of(context).logIn,
                                                onPressed: onLoginSubmit),
                                          ),
                                          //Fingerprint Login Spacer
                                          AppVariables.isLocalAuthEnabled ==
                                                      false ||
                                                  AppVariables
                                                          .isLocalAuthEnabled ==
                                                      null
                                              ? const SizedBox()
                                              : SizedBox(width: 10.w),
                                          //Fingerprint Login Button
                                          AppVariables.isLocalAuthEnabled ==
                                                      false ||
                                                  AppVariables
                                                          .isLocalAuthEnabled ==
                                                      null
                                              ? const SizedBox()
                                              : Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.r),
                                                      color: GlobalColors
                                                          .appColor
                                                          .withValues(
                                                              alpha:
                                                                  0.1), // Soft background for fingerprint
                                                    ),
                                                    child: CustomIconButton(
                                                      onPressed: () async {
                                                        await readFromSharedPref();
                                                      },
                                                      icon: const Icon(
                                                        Icons.fingerprint,
                                                        color: GlobalColors
                                                            .appColor,
                                                        size: 32,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                SizedBox(height: 25.h),

                                // --- Register Link ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // 👉 Use pushNamed instead of pushReplacementNamed
                                        context.pushNamed(
                                          'register',
                                          queryParameters: {
                                            'issuercode': '',
                                            'memberReferralCode': '',
                                          },
                                        );
                                      },
                                      child: Text(
                                        "Register Now",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: GlobalColors.appColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        // Error State
                        else if (locationState is LocationAllErrorState) {
                          return const Error1();
                        }
                        // if none the state is executable
                        else {
                          return const SizedBox();
                        }
                      },
                    ), //Location
                  ),
                ));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  // --- LOGIC METHODS REMAIN UNCHANGED BELOW THIS LINE ---

  onLoginSubmit() async {
    setState(() {
      isLoading = true;
    });
    if (selectedCountryID == null) {
      GlobalSnackBar.valid(context, S.of(context).pleaseSelectCountryPrefix);
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (numController.text.isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).enterValidMobileNumber);
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (passwordController.text.isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).enterValidPassword);
      setState(() {
        isLoading = false;
      });
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    var res = await DioLogin().userLogin(
      loginReqModel: LoginReqModel(
        phoneNumberPrefix: selectedPhonePrefix!,
        emailPhone: numController.text.trim(),
        password: passwordController.text.trim(),
        countryId: selectedCountryID.toString(),
        lang: AppVariables.selectedLanguageNow,
      ),
    );
    if (res is LoginResModel) {
      if (res.status == 'Success') {
        // Saving the token
        Pref().writeData(key: saveToken, value: res.data!.accessToken!);
        // save Issuer Type
        Pref().writeData(key: issuerType, value: res.data!.user!.issuerType!);
        // Saving the Country ID
        Pref().writeData(
            key: saveCountryID, value: res.data!.user!.countryId.toString());
        Pref().writeData(
            key: userChosenLocationName, value: res.data!.user!.countryName!);
        //Saving State
        Pref().writeData(
            key: userChosenCountryStateName,
            value: res.data!.user!.countryName!);
        Pref().writeData(
            key: userChosenLocationID,
            value: res.data!.user!.countryId!.toString());

        // Calling the location get all Api for saving the user member country currency symbol
        LocationGetAllResModel? countryCurrency =
            await DioLocation().getCurrency();
        if (countryCurrency is LocationGetAllResModel) {
          Pref().writeData(
              key: saveCurrency,
              value: countryCurrency.data![0].currencySymbol!);
        } else {
          if (!mounted) return;
          GlobalSnackBar.showError(
              context,
              S
                  .of(context)
                  .somethingWentWrongCouldnTFetchCountryCurrencyWhenLoggingIn);
          setState(() {
            isLoading = false;
          });
        }

        // Calling the user profile to save the country origin ID and user ID
        UserProfileResModel? countryOriginID =
            await DioMemberShip().getUserProfile();
        if (countryOriginID is UserProfileResModel) {
          //originCountryId
          Pref().writeData(
              key: saveCountryOriginID,
              value: countryOriginID.data!.results!.originCountryId.toString());
          //User ID
          Pref().writeData(
              key: saveUserID,
              value: countryOriginID.data!.results!.id.toString());
        } else {
          if (!mounted) return;
          GlobalSnackBar.showError(
              context,
              S
                  .of(context)
                  .somethingWentWrongCouldnTFetchMemberOriginCountryIdAndMemberIdWhenLoggingIn);
          setState(() {
            isLoading = false;
          });
        }

        //Calling API to fetch the stripe key
        StripeKeyResModel? getStripeKey = await DioCommon().getStripe();
        if (getStripeKey is StripeKeyResModel) {
          Pref().writeData(
              key: savePublishableKey,
              value: getStripeKey.data!.stripePublishableKey ??
                  stripePublishableKey);
          initializeFlutterStripe();
        } else {
          if (!mounted) return;
          GlobalSnackBar.showError(
              context,
              S
                  .of(context)
                  .somethingWentWrongCouldnTFetchTheStripeKeyWhenLoggingIn);
          setState(() {
            isLoading = false;
          });
        }
        AppVariables.initNotifications = true;
        AppVariables.accessToken = res.data!.accessToken;
        checkSavedCredentials(res.data!.accessToken!);
        // Navigating to the Next Screen after successful login
        if (!mounted) return;
        bool canGoHome = await checkWalletBalance();
        if (canGoHome) {
          context.pushReplacementNamed('bottom-bar',
              pathParameters: {'page': '0'});
        } else {
          showPaidFreeScreen(); // redirect to top up / warning
        }
      }
    } else if (res is ErrorResModel) {
      if (!mounted) return;
      GlobalSnackBar.showError(context, res.message!);
      setState(() {
        //  numController.clear();
        passwordController.clear();
        isLoading = false;
      });
      return;
    } else {
      if (!mounted) return;
      GlobalSnackBar.showError(
          context, S.of(context).pleaseEnterCorrectMobileNumber);
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  // forgot password
  forgotPopUp(List<Datum> locationList, List<phone_pre.Datum> phonePrefixList) {
    return showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                isLoadingF = false;
                context.pop();
              },
              child: AlertDialog(
                insetPadding: const EdgeInsets.only(
                    bottom: 70.0, left: 20.0, right: 20.0),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 30.0),
                content: Text(
                  S.of(context).enterDetails,
                  textAlign: TextAlign.center,
                  style: topicStyle,
                ),
                actions: [
                  StatefulBuilder(builder: (context, stateMod) {
                    return Column(
                      children: [
                        DropdownButtonWidget(
                          label: S.of(context).selectCountryA,
                          searchController: countrySearchController,
                          items: locationList.map((e) {
                            return DropdownMenuItem(
                              value: e.countryName,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: AutoSizeText(
                                  '(${e.phonePrefix}) ${e.countryName!}',
                                  style: dopdownTextStyle,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newVal) async {
                            stateMod(() {});
                            setState(() {
                              selectedCountry = newVal as String;
                            });
                            final locationID = locationList.firstWhere(
                                (element) =>
                                    element.countryName == selectedCountry);
                            selectedCountryID = locationID.id!;
                            selectedPhonePrefix = locationID.phonePrefix;
                          },
                          value: selectedCountry,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: TextFormField(
                            controller: numController,
                            cursorColor: GlobalColors.appColor,
                            keyboardType: TextInputType.number,
                            decoration: textInputDecoration1.copyWith(
                                hintText: S.of(context).mobileNumberA),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]*'))
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Send OTP Button
                        isLoadingF == true
                            ? const CustomButtonWithCircular()
                            : CustomButton(
                                text: S.of(context).sendOtp,
                                onPressed: () async {
                                  if (selectedCountryID == null) {
                                    GlobalSnackBar.valid(context,
                                        S.of(context).pleaseSelectCountry);
                                    return;
                                  }
                                  if (selectedPhonePrefix == null) {
                                    GlobalSnackBar.valid(context,
                                        S.of(context).enterValidMobileNumber);
                                    return;
                                  }
                                  if (numController.text.isEmpty) {
                                    GlobalSnackBar.valid(context,
                                        S.of(context).enterValidMobileNumber);
                                    return;
                                  }

                                  stateMod(() {
                                    isLoadingF = true;
                                  });

                                  var res = await DioLogin().forgotPassword(
                                    phoneNumberPrefix: selectedPhonePrefix!,
                                    countryId: selectedCountryID!,
                                    phoneNumber: numController.text,
                                    appSign: getAsign,
                                  );
                                  if (!mounted) return;
                                  if (res is ForgotPasswordResModel) {
                                    if (res.status == 'Success') {
                                      stateMod(() {
                                        isLoadingF = false;
                                      });
                                      successMessage =
                                          '${S.of(context).otpHasBeenSentToYour} ${res.emailOTPSent == true ? '${S.of(context).emailAnd} ' : ''}${S.of(context).phoneNum}';
                                      GlobalSnackBar.showSuccess(
                                          context, successMessage);
                                      context.pop();
                                      newPasswordController.clear();
                                      confirmNewPasswordController.clear();
                                      resetOTPController.clear();
                                      // _timerOn.value = true;
                                      resetPopUp();
                                      // resetTimer();
                                    } else if (res.status == 'FAIL') {
                                      stateMod(() {
                                        isLoadingF = false;
                                      });
                                      GlobalSnackBar.showError(
                                          context,
                                          res.message ??
                                              S
                                                  .of(context)
                                                  .enterValidCredentials);
                                    }
                                  } else {
                                    stateMod(() {
                                      isLoadingF = false;
                                    });
                                    GlobalSnackBar.showError(context,
                                        S.of(context).enterValidCredentials);
                                  }
                                },
                              ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        });
  }

  // reset password
  resetPopUp() {
    //bool for tracking the pop up
    bool trackResetDialog = false;
    Timer? timer;
    const int timerMaxSeconds = 121;
    int currentSeconds = 0;

    startTimer() {
      _timerState.value = '';
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        currentSeconds = timer.tick;
        _timerState.value =
            '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';
        if (timer.tick >= timerMaxSeconds) {
          Future.delayed(const Duration(seconds: 1), () {
            _timerState.value = '00:00';
            timer.cancel();
          });
        }
      });
    }

    startTimer();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              timer?.cancel();
              return true;
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: AlertDialog(
                scrollable: true,
                insetPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 20.0),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 30.0),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).resetPassword,
                      textAlign: TextAlign.center,
                      style: topicStyle,
                    ),
                    GestureDetector(
                      onTap: () {
                        isLoadingR = false;
                        timer?.cancel();
                        context.pop();
                      },
                      child: const Icon(
                        Icons.cancel,
                        color: GlobalColors.appColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                actions: [
                  StatefulBuilder(builder: (context, stateMod1) {
                    return Form(
                      key: resetKey,
                      child: Column(
                        children: [
                          // email
                          SizedBox(
                            child: TextFormField(
                              controller: numController,
                              style: locationStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              decoration: textInputDecoration1.copyWith(
                                hintText: S.of(context).mobileNumber,
                              ),
                              enabled: false,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // OTP
                          SizedBox(
                            child: TextFormField(
                              controller: resetOTPController,
                              cursorColor: GlobalColors.appColor,
                              decoration: textInputDecoration1.copyWith(
                                hintText: S.of(context).otp,
                              ),
                              validator: (resetOTP) {
                                if (resetOTP == null || resetOTP.isEmpty) {
                                  stateMod1(() {
                                    isLoadingR = false;
                                  });
                                  return S.of(context).pleaseFillTheOTPField;
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // new password
                          SizedBox(
                            child: TextFormField(
                              controller: newPasswordController,
                              cursorColor: GlobalColors.appColor,
                              decoration: textInputDecoration1.copyWith(
                                hintText: S.of(context).password,
                                suffix: GestureDetector(
                                  onTap: () {
                                    stateMod1(() {
                                      _isHidden1 = !_isHidden1;
                                    });
                                  },
                                  child: _isHidden1
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
                              obscureText: _isHidden1,
                              validator: (newPassword) {
                                if (newPassword == null ||
                                    newPassword.isEmpty) {
                                  stateMod1(() {
                                    isLoadingR = false;
                                  });
                                  return S.of(context).pleaseEnterPassword;
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // new confirm password
                          SizedBox(
                            child: TextFormField(
                              controller: confirmNewPasswordController,
                              cursorColor: GlobalColors.appColor,
                              decoration: textInputDecoration1.copyWith(
                                hintText: S.of(context).confirmPassword,
                                suffix: GestureDetector(
                                  onTap: () {
                                    stateMod1(() {
                                      _isHidden2 = !_isHidden2;
                                    });
                                  },
                                  child: _isHidden2
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
                              obscureText: _isHidden2,
                              validator: (confirmPassword) {
                                if (confirmPassword == null ||
                                    confirmPassword.isEmpty ||
                                    confirmPassword !=
                                        newPasswordController.text.trim()) {
                                  stateMod1(() {
                                    isLoadingR = false;
                                  });
                                  return S
                                      .of(context)
                                      .confirmPasswordDoesNotMatch;
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Reset Button
                          isLoadingR == true
                              ? const CustomButtonWithCircular()
                              : CustomButton(
                                  text: S.of(context).resetPassword,
                                  onPressed: () async {
                                    stateMod1(() {
                                      isLoadingR = true;
                                    });
                                    if (resetKey.currentState!.validate()) {
                                      var res = await DioLogin().resetPassword(
                                        resetPasswordReqModel:
                                            ResetPasswordReqModel(
                                          countryId: selectedCountryID!,
                                          phoneNumber:
                                              numController.text.trim(),
                                          otp: resetOTPController.text.trim(),
                                          newPassword:
                                              newPasswordController.text.trim(),
                                          newConfirmPassword:
                                              newPasswordController.text.trim(),
                                          phoneNumberPrefix:
                                              selectedPhonePrefix!,
                                        ),
                                      );

                                      if (!mounted) return;
                                      if (res is CommonResModel) {
                                        if (res.status == 'Success') {
                                          stateMod1(() {
                                            trackResetDialog = true;
                                            Pref().writeData(
                                                key: 'savePassword',
                                                value: newPasswordController
                                                    .text
                                                    .trim());
                                          });
                                          stateMod1(() {
                                            isLoadingR = false;
                                          });
                                          context.pop();
                                        } else if (res.status == 'FAIL') {
                                          GlobalSnackBar.showError(
                                              context,
                                              res.message ??
                                                  S
                                                      .of(context)
                                                      .somethingWentWrong);
                                          stateMod1(() {
                                            isLoadingR = false;
                                          });
                                        }
                                      } else {
                                        GlobalSnackBar.showError(context,
                                            S.of(context).somethingWentWrong);
                                        stateMod1(() {
                                          isLoadingR = false;
                                        });
                                      }
                                    }
                                  },
                                ),

                          const SizedBox(height: 20),

                          //Resend the forgot password OTP
                          ValueListenableBuilder(
                              valueListenable: _timerState,
                              builder: (context, value, child) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Resend OTP
                                    InkWell(
                                      onTap: () async {
                                        stateMod1(() {
                                          resetOTPController.clear();
                                          startTimer();
                                        });

                                        var res =
                                            await DioLogin().forgotPassword(
                                          phoneNumberPrefix:
                                              selectedPhonePrefix!,
                                          countryId: selectedCountryID!,
                                          phoneNumber: numController.text,
                                          appSign: getAsign,
                                        );
                                        if (!mounted) return;
                                        if (res is ForgotPasswordResModel) {
                                          successMessage =
                                              '${S.of(context).otpHasBeenSentToYour} ${res.emailOTPSent == true ? '${S.of(context).emailAnd} ' : ''}${S.of(context).phoneNum}';
                                          if (res.status == 'Success') {
                                            GlobalSnackBar.showSuccess(
                                                context, successMessage);
                                          }
                                        } else {
                                          GlobalSnackBar.showError(context,
                                              S.of(context).couldnTResendOtp);
                                          timer?.cancel();
                                        }
                                      },
                                      child: value == '00:00'
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 25.0),
                                                child: Text(
                                                  S.of(context).resendOtp,
                                                  style: textStyle15h.copyWith(
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const Text(''),
                                    ),
                                    Row(
                                      key: UniqueKey(),
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(Icons.timer,
                                            color: GlobalColors.appColor),
                                        const SizedBox(width: 5),
                                        Text(value)
                                      ],
                                    ),
                                  ],
                                );
                              }),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }).then((value) => trackResetDialog ==
            true
        ? GlobalSnackBar.showSuccess(
            context, S.of(context).passwordChangedSuccessfully)
        : null);
  }
}
