import 'dart:async';
// import 'dart:developer';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/services/location_service.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_button.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/read_sms_otp.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/connectivity/cubit/internet_cubit.dart';
import 'package:new_piiink/features/location/bloc/location_all_blocs.dart';
import 'package:new_piiink/features/location/bloc/location_all_events.dart';
import 'package:new_piiink/features/location/bloc/location_all_states.dart';
import 'package:new_piiink/features/location/services/dio_location.dart';
import 'package:new_piiink/features/register/services/dio_register.dart';
import 'package:new_piiink/models/request/phone_otp_req.dart';
import 'package:new_piiink/models/request/premium_validity_req.dart';
import 'package:new_piiink/models/request/reg_member_otp_req.dart';
import 'package:new_piiink/models/response/check_issuer_res.dart';
import 'package:new_piiink/models/response/common_res.dart';
import 'package:new_piiink/models/response/get_app_slugs_res_model.dart';
import 'package:new_piiink/models/response/location_get_all.dart';
import 'package:new_piiink/models/response/nearby_charity_res.dart';
import 'package:new_piiink/models/response/state_get_all.dart';

import '../../../common/app_variables.dart';
import '../../../common/widgets/dropdown_button_widget.dart';
import '../../../models/request/nearby_req.dart';
import '../../../models/response/country_wise_prefix_res_model.dart';
import '../../../models/response/sms_validation_res_model.dart';
import '../../charity/services/dio_charity.dart';
import '../../connectivity/screens/connectivity.dart';
import '../../connectivity/screens/connectivity_screen.dart';
import '../../profile/widget/info_popup.dart';
import 'package:new_piiink/generated/l10n.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  final String? issuercode;
  final String? memberReferralCode;

  const RegisterScreen({super.key, this.issuercode, this.memberReferralCode});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController countrySearchController = TextEditingController();
  final TextEditingController charitySearchController = TextEditingController();
  final TextEditingController stateSearchController = TextEditingController();
  final TextEditingController providerController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassowrdController =
      TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController premiumController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  final TextEditingController phonePrefixSearchController =
      TextEditingController();

  final TextEditingController otpSearchController = TextEditingController();

  var reg = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  // For check box
  bool isChecked = false;

  // For seeing password
  bool _isHidden = true;
  bool _isHidden1 = true;

  //For stopping selection of state when country is changed
  bool iscountryChanged = false;

  // For dropDown of selecting country
  String? selectedCountry;
  int? selectedCountryID;
  String? selectedPhonePrefix;
  String? previousPhonePrefix;
  String? selectedSmsValType;
  String? smsOtpMedium;
  String? selectedCharity;
  int? selectedCharityID;
  String? slugg;
  String? infoTitile;
  String? infoMessage;
  bool isSlugLoading = false;
  bool isSlugLoading1 = false;

  Future<StateGetAllResModel?>? stateList;
  Future<StateGetAllResModel?> getState() async {
    StateGetAllResModel? stateGetAllResModel =
        await DioLocation().getAllState(countryID: selectedCountryID!);
    setState(() {
      iscountryChanged = false;
    });
    return stateGetAllResModel;
  }

  Future<CountryWisePrefixResModel?>? phonePrefixList;
  Future<CountryWisePrefixResModel?> getPhonePrefix() async {
    CountryWisePrefixResModel? countryWisePrefixResModel =
        await DioRegister().countryPhonePrefix();
    return countryWisePrefixResModel;
  }

//Calling API of GetAll Charity
  Future<NearByCharityListResModel?>? nearByCharityForReg;
  Future<NearByCharityListResModel?>? getNearByCharityForReg(
      int countryId) async {
    NearByCharityListResModel? nearByCharityListResModel =
        await DioCharity().getNearByCharity(
      nearByLocationReqModel: NearByLocationReqModel(
        countryId: countryId,
        latitude: AppVariables.latitude,
        longitude: AppVariables.longitude,
        radius: 50,
        lang: AppVariables.selectedLanguageNow,
      ),
    );
    return nearByCharityListResModel;
  }

  Future<SmsValidationModel?>? otpTypeList;
  Future<SmsValidationModel?> getOtpTypeDropDown() async {
    SmsValidationModel? smsValidationModel = await DioRegister().getOtpType();
    return smsValidationModel;
  }

  Future<void> getAppSlugs(String? slugg) async {
    setState(() {
      if (slugg == 'referral-code') {
        isSlugLoading1 = true;
      } else if (slugg == 'issuer-code') {
        isSlugLoading = true;
      }
    });
    GetAppSlugResModel? getAppSlugResModel =
        await DioRegister().getAppSlugMessages(slugg);
    infoTitile = getAppSlugResModel!.data!.slug;
    infoMessage = getAppSlugResModel.data!.information;
    setState(() {
      isSlugLoading = false;
      isSlugLoading1 = false;
    });
  }

  // For dropDown of selecting state
  String? selectedState;
  int? selectedStateID;

  //For checking the phone number is valid with its country code or not
  String? selectedCountryShortName;

  //Flutter BarCode Scanner for Provider Info
  providerScanResult(String value) async {
    // await FlutterBarcodeScanner.scanBarcode(
    //         '#EC4785', 'Cancel', true, ScanMode.QR)
    //     .then((value) {
    if (value.contains('https://')) {
      var uri = Uri.parse(value.toString());
      if (uri.queryParameters['issuercode'] != null) {
        providerController.text = uri.queryParameters['issuercode'].toString();
      } else {
        providerController.text = value == '-1' ? '' : value;
      }
    } else {
      providerController.text = value == '-1' ? '' : value;
    }
    // });
  }

  //Flutter BarCode Scanner for Member Referral Code
  referralCodeScanResult(String value) async {
    // await FlutterBarcodeScanner.scanBarcode(
    //         '#EC4785', 'Cancel', true, ScanMode.QR)
    //     .then((value) {
    if (value.contains('https://')) {
      var uri = Uri.parse(value.toString());
      if (uri.queryParameters['memberReferralCode'] != null) {
        referralCodeController.text =
            uri.queryParameters['memberReferralCode'].toString();
      } else {
        referralCodeController.text = value == '-1' ? '' : value;
      }
    } else {
      referralCodeController.text = value == '-1' ? '' : value;
    }
    // });
  }

  // For the Loading part
  var isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      phonePrefixList = getPhonePrefix();
      // allCharityy = getAllCharityy();
      providerController.text = widget.issuercode ?? '';
      referralCodeController.text = widget.memberReferralCode ?? '';
      setState(() {});
    });
    super.initState();
  }

  dialogInfo(String infoText) {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true, //to dismiss the container once opened
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: InfoPopUp1(
            body: infoMessage ?? '',
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

  @override
  void dispose() {
    ConnectivityCubit().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List arr = S.of(context).iAgreeWithTheTermsAndCondition.split(" ");
    // List iagree = S.of(context).iAgreeWithTheTermsAndCondition.split("&");
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            text: S.of(context).registration,
            icon: Icons.arrow_back_ios,
            onPressed: (() {
              context.pop();
            }),
          ),
        ),
        body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, state) {
            if (state == ConnectivityState.loading) {
              return const NoInternetLoader();
            } else if (state == ConnectivityState.disconnected) {
              return const NoConnectivityScreen();
            } else if (state == ConnectivityState.connected) {
              return BlocProvider(
                lazy: false,
                create: (context) =>
                    LocationAllBloc(RepositoryProvider.of<DioLocation>(context))
                      ..add(LoadLocationAllEvent()),

                child: BlocBuilder<LocationAllBloc, LocationAllState>(
                  builder: (context, locationState) {
                    // Loading State
                    if (locationState is LocationAllLoadingState) {
                      return const Column(
                        children: [
                          CustomAllLoader(),
                        ],
                      );
                    }
                    // Loaded State
                    else if (locationState is LocationAllLoadedState) {
                      LocationGetAllResModel locationList =
                          locationState.locationGetAll; //Location
                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: GlobalColors.appWhiteBackgroundColor,
                              borderRadius: BorderRadius.circular(5),
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
                              // Select Country
                              SizedBox(
                                width: double.infinity,
                                child: DropdownButtonWidget(
                                  label: S
                                      .of(context)
                                      .selectCountryA
                                      .replaceFirst('Prefix', ''),
                                  lPadding: 15,
                                  searchController: countrySearchController,
                                  items: locationList.data!.map((e) {
                                    return DropdownMenuItem(
                                      value: e.countryName,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: AutoSizeText(
                                          e.countryName!,
                                          style: dopdownTextStyle,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newVal) async {
                                    setState(() {
                                      selectedCountry = newVal as String;
                                      iscountryChanged = true;
                                      countrySearchController.clear();
                                    });
                                    final locationID = locationList.data!
                                        .firstWhere((element) =>
                                            element.countryName ==
                                            selectedCountry);
                                    previousPhonePrefix =
                                        locationID.phonePrefix;
                                    selectedPhonePrefix =
                                        locationID.phonePrefix;
                                    selectedCountryID = locationID.id!;
                                    selectedCountryShortName =
                                        locationID.countryShortName;
                                    //calling the state api
                                    setState(() {
                                      selectedState = null;
                                      stateList = getState();
                                      if (AppVariables
                                              .locationEnabledStatus.value >=
                                          2) {
                                        setState(() {
                                          nearByCharityForReg =
                                              getNearByCharityForReg(
                                                  selectedCountryID!);
                                        });
                                      }
                                    });
                                  },
                                  value: selectedCountry,
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Select State
                              FutureBuilder<StateGetAllResModel?>(
                                  future: stateList,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container(
                                        padding: const EdgeInsets.only(
                                            left: 25, right: 25, top: 15),
                                        height: 50.h,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: GlobalColors.paleGray,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: AutoSizeText(
                                          S.of(context).selectStateProvince,
                                          style: TextStyle(
                                              color: GlobalColors.gray
                                                  .withValues(alpha: 0.8),
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        height: 50.h,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: GlobalColors.paleGray,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: snapshot.data!.data!.isEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0,
                                                    left: 25.0,
                                                    right: 25.0),
                                                child: AutoSizeText(
                                                  S
                                                      .of(context)
                                                      .noStateAvailable,
                                                  style: locationStyle.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              )
                                            : iscountryChanged == true
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15,
                                                            left: 25,
                                                            right: 25),
                                                    child: AutoSizeText(
                                                      S.of(context).pleaseWait,
                                                      style: locationStyle
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  )
                                                : DropdownButtonWidget(
                                                    label: S
                                                        .of(context)
                                                        .selectStateProvince,
                                                    searchController:
                                                        stateSearchController,
                                                    lPadding: 15,
                                                    items: snapshot.data!.data!
                                                        .map((e) {
                                                      return DropdownMenuItem(
                                                        value: e.stateName,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 20),
                                                          child: Text(
                                                            e.stateName!,
                                                            style:
                                                                dopdownTextStyle,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (newVal) async {
                                                      setState(() {
                                                        selectedState =
                                                            newVal as String;
                                                      });
                                                      final stateID = snapshot
                                                          .data!.data!
                                                          .firstWhere((element) =>
                                                              element
                                                                  .stateName ==
                                                              selectedState);
                                                      selectedStateID =
                                                          stateID.id;
                                                    },
                                                    value: selectedState,
                                                  ),
                                      );
                                    }
                                  }),
                              const SizedBox(height: 15),

                              // Scan Provider code
                              Row(
                                children: [
                                  Expanded(
                                    flex: 15,
                                    child: TextFormField(
                                      controller: providerController,
                                      cursorColor: GlobalColors.appColor,
                                      decoration: textInputDecoration1.copyWith(
                                          // label: GestureDetector(
                                          //   onTap: () {
                                          //     log('he');
                                          //     const Tooltip(
                                          //       message: 'Hello this is issuer code s',
                                          //     );
                                          //   },
                                          //   child: const Icon(
                                          //     Icons.info,
                                          //     size: 30,
                                          //     color: GlobalColors.appColor,
                                          //   ),
                                          // ),
                                          // floatingLabelBehavior:
                                          //     FloatingLabelBehavior.always,
                                          hintText: S
                                              .of(context)
                                              .enterOrScanIssuerCode,
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              context.pushNamed('qr_screen',
                                                  extra: {
                                                    'title': S
                                                        .of(context)
                                                        .scanIssuerCode
                                                  }).then((value) {
                                                // log(value.toString());
                                                if (value != null) {
                                                  providerScanResult(
                                                      value.toString());
                                                }
                                              });
                                            },
                                            // providerScanResult(),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: Image.asset(
                                                "assets/images/icon_qr_code.png",
                                                color: GlobalColors.appColor,
                                                height: 20,
                                                width: 20,
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                  Expanded(
                                    child: isSlugLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1,
                                              color: GlobalColors.appColor,
                                              backgroundColor:
                                                  GlobalColors.appColor1,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () async {
                                              await getAppSlugs('issuer-code');
                                              dialogInfo(infoMessage ?? '__');
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: const Icon(
                                              Icons.info,
                                              size: 25,
                                              color: GlobalColors.appColor,
                                            )),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              // First Name
                              TextFormField(
                                controller: firstNameController,
                                cursorColor: GlobalColors.appColor,
                                decoration: textInputDecoration1.copyWith(
                                    hintText: S.of(context).firstName),
                              ),

                              const SizedBox(height: 15),

                              // Last Name
                              TextFormField(
                                controller: lastNameController,
                                cursorColor: GlobalColors.appColor,
                                decoration: textInputDecoration1.copyWith(
                                    hintText: S.of(context).lastName),
                              ),
                              const SizedBox(height: 15),

                              // E-mail
                              TextFormField(
                                controller: emailController,
                                cursorColor: GlobalColors.appColor,
                                decoration: textInputDecoration1.copyWith(
                                    hintText: S.of(context).email),
                              ),
                              const SizedBox(height: 15),

                              // Password
                              TextFormField(
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
                                obscureText: _isHidden,
                              ),

                              const SizedBox(height: 15),

                              // Confirm Password
                              TextFormField(
                                controller: confirmPassowrdController,
                                cursorColor: GlobalColors.appColor,
                                decoration: textInputDecoration1.copyWith(
                                  hintText: S.of(context).confirmPasswordA,
                                  suffix: GestureDetector(
                                    onTap: () {
                                      setState(() {
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
                              ),

                              const SizedBox(height: 15),

                              FutureBuilder<CountryWisePrefixResModel?>(
                                  future: phonePrefixList,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Error1();
                                    } else if (!snapshot.hasData) {
                                      return Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: AutoSizeText(
                                              S.of(context).pleaseWaitD,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: GlobalColors.gray
                                                      .withValues(alpha: 0.8),
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: AutoSizeText(
                                              S.of(context).pleaseWaitD,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: GlobalColors.gray
                                                      .withValues(alpha: 0.8),
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: SizedBox(
                                              height: 55.h,
                                              child: DropdownButtonWidget(
                                                label: S.of(context).prefix,
                                                // 'Prefix*',
                                                dropWidth: 140.w,
                                                lPadding: 3,
                                                searchController:
                                                    phonePrefixSearchController,
                                                items: snapshot.data!.data!
                                                    .map((e) {
                                                  return DropdownMenuItem(
                                                    value: e.phonePrefix,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 20,
                                                            width: 25,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withValues(
                                                                            alpha:
                                                                                0.4))),
                                                            child:
                                                                Image.network(
                                                              e.logoUrl ??
                                                                  '', // Pass empty string if null to trigger the errorBuilder
                                                              fit: BoxFit.fill,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                // If the image fails to load, show a default flag icon instead of a broken box
                                                                return const Icon(
                                                                  Icons.flag,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .grey,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          AutoSizeText(
                                                            e.phonePrefix!,
                                                            style:
                                                                dopdownTextStyle,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (newVal) async {
                                                  setState(() {
                                                    selectedPhonePrefix =
                                                        newVal as String;
                                                    phonePrefixSearchController
                                                        .clear();
                                                  });
                                                  otpTypeList =
                                                      getOtpTypeDropDown();
                                                },
                                                value: selectedPhonePrefix,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: TextFormField(
                                              controller:
                                                  mobileNumberController,
                                              cursorColor:
                                                  GlobalColors.appColor,
                                              decoration:
                                                  textInputDecoration1.copyWith(
                                                hintText:
                                                    S.of(context).mobNumWop,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]*'))
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  }),
                              const SizedBox(height: 15),

                              previousPhonePrefix != selectedPhonePrefix
                                  ? Column(children: [
                                      const SizedBox(height: 15),
                                      AutoSizeText(
                                        S
                                            .of(context)
                                            .mobileNumberPrefixIsDifferentThanTheCountryYouHaveChosenPleaseChooseOneOfTheFollowingOptionForMobileNumberVerification,
                                        //     'Mobile Number prefix is different than the country you have chosen. Please choose one of the following option for Mobile Number Verification',
                                        style: noteTextStyle,
                                      ),
                                      const SizedBox(height: 15),
                                      // Select SMS service
                                      FutureBuilder<SmsValidationModel?>(
                                          future: otpTypeList,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Container(
                                                padding: const EdgeInsets.only(
                                                    left: 25,
                                                    right: 25,
                                                    top: 15),
                                                height: 50.h,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: GlobalColors.paleGray,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                child: AutoSizeText(
                                                  S.of(context).error,
                                                  // 'Error',
                                                  style: TextStyle(
                                                      color: GlobalColors.gray
                                                          .withValues(
                                                              alpha: 0.8),
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              );
                                            } else if (!snapshot.hasData) {
                                              return Container(
                                                padding: const EdgeInsets.only(
                                                    left: 25,
                                                    right: 25,
                                                    top: 15),
                                                height: 50.h,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: GlobalColors.paleGray,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                child: AutoSizeText(
                                                  S.of(context).pleaseWaitD,
                                                  // 'Please wait...',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: GlobalColors.gray
                                                          .withValues(
                                                              alpha: 0.8),
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              );
                                            } else {
                                              return Container(
                                                height: 50.h,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: GlobalColors.paleGray,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                child: snapshot
                                                        .data!.data!.isEmpty
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 15.0,
                                                                left: 25.0,
                                                                right: 25.0),
                                                        child: AutoSizeText(
                                                          S
                                                              .of(context)
                                                              .noSmsTypeAvailable,
                                                          // 'No Sms Type Available',
                                                          style: locationStyle
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                      )
                                                    : DropdownButtonWidget(
                                                        label: S
                                                            .of(context)
                                                            .selectServiceForSMSValidation,
                                                        //   'Select Service for SMS Validation*',
                                                        searchController:
                                                            otpSearchController,
                                                        items: snapshot
                                                            .data!.data!
                                                            .map((e) {
                                                          return DropdownMenuItem(
                                                            value: e
                                                                .mediumDisplayName,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 25),
                                                              child: Text(
                                                                e.mediumDisplayName
                                                                    .toString(),
                                                                style:
                                                                    dopdownTextStyle,
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged:
                                                            (newVal) async {
                                                          setState(() {
                                                            selectedSmsValType =
                                                                newVal
                                                                    as String;
                                                          });
                                                          final smsID = snapshot
                                                              .data!.data!
                                                              .firstWhere((element) =>
                                                                  element
                                                                      .mediumDisplayName ==
                                                                  selectedSmsValType);
                                                          smsOtpMedium =
                                                              smsID.medium;
                                                        },
                                                        value:
                                                            selectedSmsValType,
                                                      ),
                                              );
                                            }
                                          }),
                                      const SizedBox(
                                        height: 10,
                                      )
                                    ])
                                  : const SizedBox(),

                              // Postal/Zip code
                              TextFormField(
                                controller: postalCodeController,
                                cursorColor: GlobalColors.appColor,
                                decoration: textInputDecoration1.copyWith(
                                    hintText:
                                        '${S.of(context).postalZipCode} (optional)'),
                              ),
                              const SizedBox(height: 15),

                              // Premium member code (optional)
                              TextFormField(
                                controller: premiumController,
                                cursorColor: GlobalColors.appColor,
                                decoration: textInputDecoration1.copyWith(
                                  hintText: S.of(context).preCode,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Referral Code (optional)
                              Row(
                                children: [
                                  Expanded(
                                    flex: 15,
                                    child: TextFormField(
                                      controller: referralCodeController,
                                      cursorColor: GlobalColors.appColor,
                                      decoration: textInputDecoration1.copyWith(
                                          hintText: S.of(context).refCode,
                                          // 'Referral Code from Your Family/Friends (optional)',
                                          hintMaxLines: 2,
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              context.pushNamed('qr_screen',
                                                  extra: {
                                                    'title': S
                                                        .of(context)
                                                        .scanReferralCode
                                                  }).then((vaz) {
                                                if (vaz != null) {
                                                  referralCodeScanResult(
                                                      vaz.toString());
                                                }
                                              });
                                            },
                                            // =>referralCodeScanResult(),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: Image.asset(
                                                "assets/images/icon_qr_code.png",
                                                color: GlobalColors.appColor,
                                                height: 20,
                                                width: 20,
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                  Expanded(
                                    child: isSlugLoading1
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1,
                                              color: GlobalColors.appColor,
                                              backgroundColor:
                                                  GlobalColors.appColor1,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () async {
                                              await getAppSlugs(
                                                  'referral-code');
                                              dialogInfo(infoMessage ?? '__');
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: const Icon(
                                              Icons.info,
                                              size: 25,
                                              color: GlobalColors.appColor,
                                            )),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              // Select Charity
                              FutureBuilder<NearByCharityListResModel?>(
                                  future: nearByCharityForReg,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container(
                                        padding: const EdgeInsets.only(
                                            left: 25, right: 25, top: 15),
                                        height: 50.h,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: GlobalColors.paleGray,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            if (selectedCountryID == null) {
                                              GlobalSnackBar.valid(
                                                  context,
                                                  S
                                                      .of(context)
                                                      .pleaseSelectCountryFirstToSelectCharity);
                                            } else if (AppVariables
                                                    .locationEnabledStatus
                                                    .value <
                                                2) {
                                              LocationService()
                                                  .enableLocationAndFetchCountry()
                                                  .then((value) {
                                                if (value == true) {
                                                  setState(() {
                                                    nearByCharityForReg =
                                                        getNearByCharityForReg(
                                                            selectedCountryID!);
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          child: AutoSizeText(
                                            S.of(context).selectCharity,
                                            // 'Select Charity',
                                            style: TextStyle(
                                                color: GlobalColors.gray
                                                    .withValues(alpha: 0.8),
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        height: 50.h,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: GlobalColors.paleGray,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: snapshot.data!.data!.isEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0,
                                                    left: 25.0,
                                                    right: 25.0),
                                                child: AutoSizeText(
                                                  S
                                                      .of(context)
                                                      .noCharityAvailable,
                                                  style: locationStyle.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              )
                                            : iscountryChanged == true
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15,
                                                            left: 25,
                                                            right: 25),
                                                    child: AutoSizeText(
                                                      S.of(context).pleaseWait,
                                                      style: locationStyle
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  )
                                                : DropdownButtonWidget(
                                                    label: S
                                                        .of(context)
                                                        .selectCharity,
                                                    searchController:
                                                        stateSearchController,
                                                    isExpanded: true,
                                                    bWidth: double.infinity,
                                                    iHeight: 35,
                                                    dropHeight: 175,
                                                    searchHeight: 40,
                                                    items: snapshot.data!.data!
                                                        .map((e) {
                                                      return DropdownMenuItem(
                                                        value: e.charityName,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 25,
                                                            top: 0,
                                                            bottom: 0,
                                                          ),
                                                          child: AutoSizeText(
                                                            e.charityName!,
                                                            style:
                                                                dopdownTextStyle,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (newVal) async {
                                                      setState(() {
                                                        selectedCharity =
                                                            newVal as String;
                                                      });
                                                      final charityIDD = snapshot
                                                          .data!.data!
                                                          .firstWhere((element) =>
                                                              element
                                                                  .charityName ==
                                                              selectedCharity);
                                                      selectedCharityID =
                                                          charityIDD.id;
                                                    },
                                                    value: selectedCharity,
                                                  ),
                                      );
                                    }
                                  }),

                              const SizedBox(height: 15),
                              // I agree with the Term and Condition
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: GlobalColors.appColor,
                                      side: const BorderSide(
                                          width: 2,
                                          color: GlobalColors.appColor),
                                      // fillColor: WidgetStateProperty.all(
                                      //     GlobalColors.appColor),
                                      value: isChecked,
                                      // shape: const CircleBorder(),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isChecked = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    flex: 9,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              text: S
                                                  .of(context)
                                                  .iAgreeWithTheTermsAndCondition
                                                  .replaceAll('&C', ''),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: S
                                                      .of(context)
                                                      .iAgreeWithTheTermsAndCondition
                                                      .replaceAll(
                                                          'I agree with the',
                                                          '')
                                                      .replaceAll(
                                                          '&C',
                                                          S
                                                              .of(context)
                                                              .termsAndConditions),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color:
                                                        GlobalColors.appColor,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          context.pushNamed(
                                                              'terms-condition'); // Navigate to terms
                                                        },
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              // submit Registration
                              isLoading == true
                                  ? const CustomButtonWithCircular()
                                  : CustomButton(
                                      text: S.of(context).submit,
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        if (selectedCountry == null) {
                                          GlobalSnackBar.valid(context,
                                              S.of(context).selectTheCountry);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (selectedState == null) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .pleaseSelectTheState);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (firstNameController
                                            .text.isEmpty) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .pleaseFillFirstName);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (lastNameController
                                            .text.isEmpty) {
                                          GlobalSnackBar.valid(context,
                                              S.of(context).pleaseFillLastName);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (!reg.hasMatch(
                                                emailController.text) ||
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
                                        } else if (passwordController
                                            .text.isEmpty) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .pleaseFillThePassword);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (confirmPassowrdController
                                            .text.isEmpty) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .pleaseFillConfirmPassword);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (confirmPassowrdController
                                                .text !=
                                            passwordController.text.trim()) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .confirmPasswordDoesNotMatch);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (selectedPhonePrefix ==
                                            null) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .pleaseSelectPhonePrefix);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (mobileNumberController
                                            .text.isEmpty) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .pleaseFillCorrectMobileNumber);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (mobileNumberController.text
                                                .trim()
                                                .length <
                                            7) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .phoneNumberShouldBeAtLeast7Digits);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if ((previousPhonePrefix !=
                                                selectedPhonePrefix) &&
                                            selectedSmsValType == null) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .pleaseSelectSMSvalidationType);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (postalCodeController
                                                .text.isNotEmpty &&
                                            postalCodeController.text.length <
                                                4) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .postalCodeShouldBeGreaterThan4Digits);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else if (isChecked == false) {
                                          GlobalSnackBar.valid(
                                              context,
                                              S
                                                  .of(context)
                                                  .pleaseAcceptTermsConditions);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        } else {
                                          // var checkingNum = await DioCommon()
                                          //     .checkCounNum(
                                          //         mobileNum: mobileNumberController
                                          //             .text
                                          //             .trim(),
                                          //         code: selectedCountryShortName!);
                                          // if (!mounted) return;
                                          // if (checkingNum == false) {
                                          //   GlobalSnackBar.valid(
                                          //       context, checkNumError);
                                          //   setState(() {
                                          //     isLoading = false;
                                          //   });
                                          //   return;
                                          // } else {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          checkProvider();
                                          //   }
                                        }
                                      },
                                    ),
                            ],
                          ),
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
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  //Check Issuer/Provider
  checkProvider() async {
    //Checking whether the Issuer/Provider code is valid or not
    if (providerController.text.isNotEmpty) {
      var proRes = await DioRegister().checkIssuerCode(
          issuerCode: providerController.text.trim(),
          countryId: selectedCountryID.toString());
      if (!mounted) return;
      if (proRes is CheckIssuerCodeResModel) {
        checkPremium();
      } else {
        setState(() {
          isLoading = false;
        });
        invalidIssuer();
      }
    } else {
      checkPremium();
    }
  }

  //Invalid Issuer/Provider Code
  invalidIssuer() {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 1.1,
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 10),
                //Text
                AutoSizeText(S.of(context).issuerCodeIsNotValid,
                    // 'Issuer Code is not Valid!',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontFamily: 'Sans')),
                const SizedBox(height: 10),

                // Button
                CustomButton(
                  text: S.of(context).ok,
                  onPressed: () {
                    context.pop();
                  },
                )
              ],
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

  //Check Premium
  checkPremium() async {
    //If premium code is not empty but issuer code is empty following code be executed
    final String premiumCodeInput = premiumController.text.trim().toUpperCase();
    if (premiumCodeInput.isNotEmpty && providerController.text.isEmpty) {
      GlobalSnackBar.valid(
          context, S.of(context).pleaseEnterIssuerCodeToUsePremiumCode);
      setState(() {
        isLoading = false;
      });
    }
    // If premium code is not empty following code will be executed to register the user
    else if (premiumCodeInput.isNotEmpty &&
        providerController.text.isNotEmpty) {
      bool? validityResult = await checkEmailAndPhoneNo();
      if (validityResult == false) {
        var preRes = await DioRegister().premiumVal(
          premiumValidityReqModel: PremiumValidityReqModel(
            memberPremiumCode: premiumCodeInput,
            issuerCode: providerController.text.trim(),
          ),
        );
        if (!mounted) return;
        if (preRes is CommonResModel) {
          if (preRes.status == 'success') {
            sendPhoneOtp();
          } else {
            GlobalSnackBar.showError(
                context, preRes.message ?? S.of(context).premiumCodeIsNotValid);
            setState(() {
              isLoading = false;
            });
          }
        }
        // If invalid premium code is provided
        else {
          setState(() {
            isLoading = false;
          });
          invalidPremium();
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // If premium code and issuer code both are empty following code will be executed to register the user
      sendPhoneOtp();
    }
  }

  //Invalid Premium Code
  invalidPremium() {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 1.1,
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                //Text
                AutoSizeText(S.of(context).premiumCodeIsNotValid,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontFamily: 'Sans')),
                const SizedBox(height: 10),

                // Button
                CustomButton(
                  text: S.of(context).ok,
                  onPressed: () {
                    context.pop();
                  },
                )
              ],
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

  Future<bool?> checkEmailAndPhoneNo() async {
    var res = await DioRegister().checkEmailAndPhoneNo(
      emailmemberOtpReqModel: EmailMemberOtpReqModel(
        phoneNumberPrefix: selectedPhonePrefix!,
        phoneNumber: mobileNumberController.text.trim(),
        email: emailController.text.trim(),
        // countryId: selectedCountryID!,
        memberReferralCode: null,
      ),
    );
    if (!mounted) return false;
    if (res == true) {
      GlobalSnackBar.showError(
          context, S.of(context).emailOrPhoneNumberAlreadyExists);
      return true;
    } else {
      return res;
    }
  }

  //sending email otp
  sendPhoneOtp() async {
    var res = await DioRegister().createPhoneOtp(
      phoneOtpReq: PhoneOtpReq(
        phoneNumberPrefix: selectedPhonePrefix,
        phoneNumber: mobileNumberController.text.trim(),
        phoneVerifiedBy: smsOtpMedium ?? 'sms',
        email: emailController.text.trim(),
        countryId: selectedCountryID!,
        appSign: getAsign,
        memberReferralCode: referralCodeController.text.trim(),
      ),
    );
    if (!mounted) return;
    if (res is CommonResModel) {
      if (res.status == 'Success') {
        GlobalSnackBar.showSuccess(context, S.of(context).otpSentSuccessfully);
        context.pushReplacementNamed('number-reg-otp', extra: {
          'countryID': selectedCountryID,
          'stateID': selectedStateID,
          'charityID': selectedCharityID ?? 0,
          'issuerCode': providerController.text.isEmpty
              ? 'null'
              : providerController.text.trim(),
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'phonePrefix': selectedPhonePrefix,
          'phoneVerifiedBy': smsOtpMedium ?? 'sms',
          'confirmPassword': confirmPassowrdController.text.trim(),
          'phNum': mobileNumberController.text.trim(),
          'postalCode': postalCodeController.text.trim(),
          'premium': premiumController.text.isEmpty
              ? 'null'
              : premiumController.text.trim().toUpperCase(),
          'referralCode': referralCodeController.text.isEmpty
              ? 'null'
              : referralCodeController.text.trim(),
        });
      }
    } else if (res == 409) {
      GlobalSnackBar.showError(
          context, S.of(context).emailOrPhoneNumberAlreadyExists);
    } else if (res.toString().contains('is not a valid phone number')) {
      // log(res.toString());
      GlobalSnackBar.showError(context, res.toString());
    } else {
      // log(res.toString());
      GlobalSnackBar.showError(context, res.toString());
    }
    setState(() {
      isLoading = false;
    });
  }
}
