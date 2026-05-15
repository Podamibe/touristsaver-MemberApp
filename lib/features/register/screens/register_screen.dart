import 'dart:async';
// import 'dart:developer';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
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
  bool _isPromoExpanded = false;

  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _fieldBorder = Color(0xFFD8DEEC);
  static const Color _softText = Color(0xFF65708D);
  static const double _inputHeight = 55;

  // For dropDown of selecting country
  String? selectedCountry;
  int? selectedCountryID;
  String? selectedPhonePrefix;
  String? selectedPhonePrefixKey;
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
    if (mounted) setState(() {});
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
    if (mounted) setState(() {});
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

  Widget _appliedAttributionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7FF),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE1E9FA)),
          ),
          child: AutoSizeText(
            text,
            style: TextStyle(
              color: _softText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _registrationHeader(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.32;

    return SizedBox(
      height: headerHeight.clamp(230.0, 310.0).toDouble(),
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/onboarding/header_au.webp',
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 12.h,
              left: 16.w,
              child: Material(
                color: Colors.white.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.pop(),
                  child: Padding(
                    padding: EdgeInsets.all(9.w),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF0D1A4A),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Icon(icon, color: _primaryBlue, size: 22.sp),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _modernInputDecoration({
    required String hintText,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: _softText.withValues(alpha: 0.82),
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: icon == null ? null : Icon(icon, color: _softText, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
    );
  }

  TextStyle get _dropdownHintStyle => TextStyle(
        color: _softText.withValues(alpha: 0.82),
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      );

  Widget _placeholderField(String text) {
    return Container(
      width: double.infinity,
      height: _inputHeight,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _fieldBorder),
      ),
      child: AutoSizeText(
        text,
        style: TextStyle(
          color: _softText.withValues(alpha: 0.82),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _promoCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () {
            setState(() {
              _isPromoExpanded = !_isPromoExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE4ECFB)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32.w,
                  child: Icon(
                    Icons.sell_outlined,
                    color: _primaryBlue,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have a promo code?',
                        style: TextStyle(
                          color: const Color(0xFF101B4D),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your discount will be applied on the payment screen',
                          maxLines: 1,
                          style: TextStyle(
                            color: _softText,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isPromoExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _primaryBlue,
                ),
              ],
            ),
          ),
        ),
        if (_isPromoExpanded) ...[
          SizedBox(height: 12.h),
          TextFormField(
            controller: premiumController,
            cursorColor: _primaryBlue,
            decoration: _modernInputDecoration(
              hintText: S.of(context).preCode,
              icon: Icons.sell_outlined,
            ),
          ),
        ],
      ],
    );
  }

  String _countryDisplayName(Object? countryName) {
    final String name = countryName?.toString() ?? '';
    return name == 'United States of America' ? 'USA' : name;
  }

  String? _countryCodeForFlag(Object? countryName) {
    switch (countryName?.toString()) {
      case 'Australia':
        return 'AU';
      case 'Canada':
        return 'CA';
      case 'China':
        return 'CN';
      case 'Fiji':
        return 'FJ';
      case 'Germany':
        return 'DE';
      case 'India':
        return 'IN';
      case 'Indonesia':
        return 'ID';
      case 'Ireland':
        return 'IE';
      case 'Lao':
        return 'LA';
      case 'Malaysia':
        return 'MY';
      case 'New Zealand':
        return 'NZ';
      case 'Philippines':
        return 'PH';
      case 'Singapore':
        return 'SG';
      case 'South Africa':
        return 'ZA';
      case 'Thailand':
        return 'TH';
      case 'United Kingdom':
        return 'GB';
      case 'United States of America':
        return 'US';
      case 'Vietnam':
        return 'VN';
    }
    return null;
  }

  String? _flagEmoji(Object? countryName) {
    final String? countryCode = _countryCodeForFlag(countryName);
    if (countryCode == null || countryCode.length != 2) return null;

    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCodes([firstLetter, secondLetter]);
  }

  Widget _fallbackFlag(Object? countryName) {
    final String? emoji = _flagEmoji(countryName);
    if (emoji != null) {
      return Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: 17.sp),
        ),
      );
    }

    return Container(
      color: const Color(0xFFEAF0F8),
      alignment: Alignment.center,
      child: Icon(
        Icons.flag_outlined,
        color: _softText,
        size: 15.sp,
      ),
    );
  }

  Widget _prefixFlag(Object? logoUrl, Object? countryName) {
    final String flagUrl = logoUrl?.toString().trim() ?? '';
    if (flagUrl.isEmpty) return _fallbackFlag(countryName);

    final String imageUrl = flagUrl;
    final bool isSvg = imageUrl.toLowerCase().contains('.svg');

    if (isSvg) {
      return SvgPicture.network(
        imageUrl,
        height: 20,
        width: 25,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _fallbackFlag(countryName),
        errorBuilder: (_, __, ___) => _fallbackFlag(countryName),
      );
    }

    return Image.network(
      imageUrl,
      height: 20,
      width: 25,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _fallbackFlag(countryName);
      },
    );
  }

  String _prefixDropdownKey(dynamic item, int index) {
    final String countryName = item.countryName?.toString() ?? '';
    final String displayName = _countryDisplayName(countryName);
    final String phonePrefix = item.phonePrefix?.toString() ?? '';
    final String id = item.id?.toString() ?? index.toString();
    return '$displayName $countryName $phonePrefix $id';
  }

  String? _selectedPrefixKey(List<dynamic> prefixItems) {
    if (selectedPhonePrefix == null) return null;

    for (var index = 0; index < prefixItems.length; index++) {
      if (_prefixDropdownKey(prefixItems[index], index) ==
          selectedPhonePrefixKey) {
        return selectedPhonePrefixKey;
      }
    }

    final int countryMatchIndex = prefixItems.indexWhere((item) =>
        item.phonePrefix?.toString() == selectedPhonePrefix &&
        item.countryName?.toString() == selectedCountry);
    if (countryMatchIndex >= 0) {
      return _prefixDropdownKey(
          prefixItems[countryMatchIndex], countryMatchIndex);
    }

    final int prefixMatchIndex = prefixItems.indexWhere(
        (item) => item.phonePrefix?.toString() == selectedPhonePrefix);
    if (prefixMatchIndex >= 0) {
      return _prefixDropdownKey(
          prefixItems[prefixMatchIndex], prefixMatchIndex);
    }

    return null;
  }

  Widget _phoneNumberFields() {
    final double prefixWidth = (MediaQuery.of(context).size.width * 0.32)
        .clamp(118.0, 145.0)
        .toDouble();
    const double prefixFieldHeight = _inputHeight - 2;

    return FutureBuilder<CountryWisePrefixResModel?>(
        future: phonePrefixList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Error1();
          } else if (!snapshot.hasData) {
            return Row(
              children: [
                SizedBox(
                  width: prefixWidth,
                  child: AutoSizeText(
                    S.of(context).pleaseWaitD,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: GlobalColors.gray.withValues(alpha: 0.8),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: AutoSizeText(
                    S.of(context).pleaseWaitD,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: GlobalColors.gray.withValues(alpha: 0.8),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          } else {
            final prefixItems = [...snapshot.data!.data!]..sort((a, b) =>
                (a.countryName ?? '')
                    .toString()
                    .toLowerCase()
                    .compareTo((b.countryName ?? '').toString().toLowerCase()));
            final prefixItemsByKey = <String, dynamic>{
              for (var index = 0; index < prefixItems.length; index++)
                _prefixDropdownKey(prefixItems[index], index):
                    prefixItems[index],
            };

            return Row(
              children: [
                SizedBox(
                  width: prefixWidth,
                  height: prefixFieldHeight,
                  child: DropdownButtonWidget(
                    label: S.of(context).prefix,
                    bWidth: prefixWidth,
                    dropWidth: 190.w,
                    lPadding: 3,
                    fillColor: Colors.white,
                    borderColor: _fieldBorder,
                    borderRadius: 12.r,
                    iconColor: _primaryBlue,
                    hintStyle: _dropdownHintStyle,
                    height: prefixFieldHeight,
                    buttonHeight: prefixFieldHeight - 2,
                    buttonPadding: EdgeInsets.only(left: 10.w, right: 0),
                    searchController: phonePrefixSearchController,
                    items: prefixItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final e = entry.value;
                      return DropdownMenuItem(
                        value: _prefixDropdownKey(e, index),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Container(
                                height: 20,
                                width: 25,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey
                                            .withValues(alpha: 0.4))),
                                clipBehavior: Clip.antiAlias,
                                child: _prefixFlag(e.logoUrl, e.countryName),
                              ),
                              const SizedBox(width: 5.0),
                              Expanded(
                                child: AutoSizeText(
                                  '${_countryDisplayName(e.countryName)} ${e.phonePrefix ?? ''}',
                                  maxLines: 1,
                                  style: dopdownTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return prefixItems.map((e) {
                        return Row(
                          children: [
                            Container(
                              height: 20,
                              width: 25,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Colors.grey.withValues(alpha: 0.4))),
                              clipBehavior: Clip.antiAlias,
                              child: _prefixFlag(e.logoUrl, e.countryName),
                            ),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: AutoSizeText(
                                e.phonePrefix ?? '',
                                maxLines: 1,
                                style: dopdownTextStyle,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    onChanged: (newVal) async {
                      final String key = newVal as String;
                      final selectedPrefixItem = prefixItemsByKey[key];
                      setState(() {
                        selectedPhonePrefix =
                            selectedPrefixItem?.phonePrefix?.toString();
                        selectedPhonePrefixKey = key;
                        phonePrefixSearchController.clear();
                      });
                      otpTypeList = getOtpTypeDropDown();
                    },
                    value: _selectedPrefixKey(prefixItems),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: SizedBox(
                    height: _inputHeight,
                    child: TextFormField(
                      controller: mobileNumberController,
                      cursorColor: _primaryBlue,
                      decoration: _modernInputDecoration(
                        hintText: 'Mobile number',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]*'))
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  Widget _postalCodeField() {
    return TextFormField(
      controller: postalCodeController,
      cursorColor: _primaryBlue,
      decoration: _modernInputDecoration(
        hintText: 'Postal/Zip Code (optional)',
        icon: Icons.location_on_outlined,
      ),
    );
  }

  Widget _countryStateFields(LocationGetAllResModel locationList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double fieldWidth = (constraints.maxWidth - 12.w) / 2;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: fieldWidth,
              child: DropdownButtonWidget(
                label: 'Country',
                bWidth: fieldWidth,
                dropWidth: fieldWidth,
                lPadding: 8,
                fillColor: Colors.white,
                borderColor: _fieldBorder,
                borderRadius: 12.r,
                iconColor: _primaryBlue,
                hintStyle: _dropdownHintStyle,
                searchController: countrySearchController,
                items: locationList.data!.map((e) {
                  return DropdownMenuItem(
                    value: e.countryName,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: AutoSizeText(
                        e.countryName!,
                        maxLines: 1,
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
                  final locationID = locationList.data!.firstWhere(
                      (element) => element.countryName == selectedCountry);
                  previousPhonePrefix = locationID.phonePrefix;
                  selectedPhonePrefix = locationID.phonePrefix;
                  selectedPhonePrefixKey = null;
                  selectedCountryID = locationID.id!;
                  selectedCountryShortName = locationID.countryShortName;
                  setState(() {
                    selectedState = null;
                    stateList = getState();
                    if (AppVariables.locationEnabledStatus.value >= 2) {
                      setState(() {
                        nearByCharityForReg =
                            getNearByCharityForReg(selectedCountryID!);
                      });
                    }
                  });
                },
                value: selectedCountry,
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: fieldWidth,
              child: FutureBuilder<StateGetAllResModel?>(
                future: stateList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _placeholderField('State/Province');
                  }

                  if (snapshot.data!.data!.isEmpty) {
                    return _placeholderField(S.of(context).noStateAvailable);
                  }

                  if (iscountryChanged == true) {
                    return _placeholderField(S.of(context).pleaseWait);
                  }

                  return DropdownButtonWidget(
                    label: 'State/Province',
                    searchController: stateSearchController,
                    bWidth: fieldWidth,
                    dropWidth: fieldWidth,
                    lPadding: 8,
                    fillColor: Colors.white,
                    borderColor: _fieldBorder,
                    borderRadius: 12.r,
                    iconColor: _primaryBlue,
                    hintStyle: _dropdownHintStyle,
                    items: snapshot.data!.data!.map((e) {
                      return DropdownMenuItem(
                        value: e.stateName,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: AutoSizeText(
                            e.stateName!,
                            maxLines: 1,
                            style: dopdownTextStyle,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newVal) async {
                      setState(() {
                        selectedState = newVal as String;
                      });
                      final stateID = snapshot.data!.data!.firstWhere(
                          (element) => element.stateName == selectedState);
                      selectedStateID = stateID.id;
                    },
                    value: selectedState,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _gradientContinueButton() {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [_primaryBlue, _ctaCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: isLoading ? null : _submitRegistration,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _submitRegistration() async {
    setState(() {
      isLoading = true;
    });

    if (selectedCountry == null) {
      GlobalSnackBar.valid(context, S.of(context).selectTheCountry);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (selectedState == null) {
      GlobalSnackBar.valid(context, S.of(context).pleaseSelectTheState);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (firstNameController.text.isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).pleaseFillFirstName);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (lastNameController.text.isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).pleaseFillLastName);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (!reg.hasMatch(emailController.text) ||
        emailController.text.isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).pleaseFillTheCorrectEmail);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (passwordController.text.isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).pleaseFillThePassword);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (confirmPassowrdController.text.isEmpty) {
      GlobalSnackBar.valid(context, S.of(context).pleaseFillConfirmPassword);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (confirmPassowrdController.text !=
        passwordController.text.trim()) {
      GlobalSnackBar.valid(context, S.of(context).confirmPasswordDoesNotMatch);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (selectedPhonePrefix == null) {
      GlobalSnackBar.valid(context, S.of(context).pleaseSelectPhonePrefix);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (mobileNumberController.text.isEmpty) {
      GlobalSnackBar.valid(
          context, S.of(context).pleaseFillCorrectMobileNumber);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (mobileNumberController.text.trim().length < 7) {
      GlobalSnackBar.valid(
          context, S.of(context).phoneNumberShouldBeAtLeast7Digits);
      setState(() {
        isLoading = false;
      });
      return;
    } else if ((previousPhonePrefix != selectedPhonePrefix) &&
        selectedSmsValType == null) {
      GlobalSnackBar.valid(
          context, S.of(context).pleaseSelectSMSvalidationType);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (postalCodeController.text.isNotEmpty &&
        postalCodeController.text.length < 4) {
      GlobalSnackBar.valid(
          context, S.of(context).postalCodeShouldBeGreaterThan4Digits);
      setState(() {
        isLoading = false;
      });
      return;
    } else if (isChecked == false) {
      GlobalSnackBar.valid(context, S.of(context).pleaseAcceptTermsConditions);
      setState(() {
        isLoading = false;
      });
      return;
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      checkProvider();
    }
  }

  @override
  Widget build(BuildContext context) {
    // List arr = S.of(context).iAgreeWithTheTermsAndCondition.split(" ");
    // List iagree = S.of(context).iAgreeWithTheTermsAndCondition.split("&");
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFE),
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
                        child: Column(
                          children: [
                            _registrationHeader(context),
                            Transform.translate(
                              offset: const Offset(0, -20),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 22.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _sectionHeader(
                                        Icons.person_outline, 'Your Details'),
                                    _countryStateFields(locationList),
                                    const SizedBox(height: 15),
                                    _postalCodeField(),
                                    const SizedBox(height: 15),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: firstNameController,
                                            cursorColor: _primaryBlue,
                                            decoration: _modernInputDecoration(
                                              hintText: S.of(context).firstName,
                                              icon: Icons.person_outline,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: TextFormField(
                                            controller: lastNameController,
                                            cursorColor: _primaryBlue,
                                            decoration: _modernInputDecoration(
                                              hintText: S.of(context).lastName,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),

                                    // E-mail
                                    TextFormField(
                                      controller: emailController,
                                      cursorColor: _primaryBlue,
                                      decoration: _modernInputDecoration(
                                        hintText: S.of(context).email,
                                        icon: Icons.email_outlined,
                                      ),
                                    ),
                                    const SizedBox(height: 15),

                                    _phoneNumberFields(),
                                    const SizedBox(height: 22),

                                    _sectionHeader(Icons.lock_outline,
                                        'Secure Your Account'),

                                    // Password
                                    TextFormField(
                                      controller: passwordController,
                                      cursorColor: _primaryBlue,
                                      decoration: _modernInputDecoration(
                                        hintText: S.of(context).passwordA,
                                        icon: Icons.lock_outline,
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isHidden = !_isHidden;
                                            });
                                          },
                                          child: Icon(
                                            _isHidden
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: _softText,
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
                                      cursorColor: _primaryBlue,
                                      decoration: _modernInputDecoration(
                                        hintText:
                                            S.of(context).confirmPasswordA,
                                        icon: Icons.lock_outline,
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isHidden1 = !_isHidden1;
                                            });
                                          },
                                          child: Icon(
                                            _isHidden1
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: _softText,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      obscureText: _isHidden1,
                                    ),

                                    previousPhonePrefix != selectedPhonePrefix
                                        ? Column(children: [
                                            const SizedBox(height: 15),
                                            AutoSizeText(
                                              'Your mobile country code differs from your selected country.',
                                              style: noteTextStyle,
                                            ),
                                            const SizedBox(height: 15),
                                            // Select SMS service
                                            FutureBuilder<SmsValidationModel?>(
                                                future: otpTypeList,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return _placeholderField(
                                                        S.of(context).error);
                                                  } else if (!snapshot
                                                      .hasData) {
                                                    return _placeholderField(S
                                                        .of(context)
                                                        .pleaseWaitD);
                                                  } else {
                                                    return Container(
                                                      height: 50.h,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: GlobalColors
                                                            .paleGray,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                      child: snapshot.data!
                                                              .data!.isEmpty
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 15.0,
                                                                      left:
                                                                          25.0,
                                                                      right:
                                                                          25.0),
                                                              child:
                                                                  AutoSizeText(
                                                                S
                                                                    .of(context)
                                                                    .noSmsTypeAvailable,
                                                                // 'No Sms Type Available',
                                                                style: locationStyle.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            )
                                                          : DropdownButtonWidget(
                                                              label:
                                                                  'SMS verification method',
                                                              searchController:
                                                                  otpSearchController,
                                                              fillColor:
                                                                  Colors.white,
                                                              borderColor:
                                                                  _fieldBorder,
                                                              borderRadius:
                                                                  12.r,
                                                              iconColor:
                                                                  _primaryBlue,
                                                              hintStyle:
                                                                  _dropdownHintStyle,
                                                              items: snapshot
                                                                  .data!.data!
                                                                  .map((e) {
                                                                return DropdownMenuItem(
                                                                  value: e
                                                                      .mediumDisplayName,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            25),
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
                                                                    smsID
                                                                        .medium;
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

                                    SizedBox(height: 22.h),
                                    _promoCodeSection(),
                                    const SizedBox(height: 15),

                                    if (referralCodeController.text
                                        .trim()
                                        .isNotEmpty)
                                      _appliedAttributionLabel(
                                          'Referral applied'),

                                    // Select Charity

                                    // FutureBuilder<NearByCharityListResModel?>(
                                    //     future: nearByCharityForReg,
                                    //     builder: (context, snapshot) {
                                    //       if (!snapshot.hasData) {
                                    //         return Container(
                                    //           padding: const EdgeInsets.only(
                                    //               left: 25, right: 25, top: 15),
                                    //           height: 50.h,
                                    //           width: double.infinity,
                                    //           decoration: BoxDecoration(
                                    //             color: GlobalColors.paleGray,
                                    //             borderRadius:
                                    //                 BorderRadius.circular(5.0),
                                    //           ),
                                    //           child: InkWell(
                                    //             onTap: () {
                                    //               if (selectedCountryID == null) {
                                    //                 GlobalSnackBar.valid(
                                    //                     context,
                                    //                     S
                                    //                         .of(context)
                                    //                         .pleaseSelectCountryFirstToSelectCharity);
                                    //               } else if (AppVariables
                                    //                       .locationEnabledStatus
                                    //                       .value <
                                    //                   2) {
                                    //                 LocationService()
                                    //                     .enableLocationAndFetchCountry()
                                    //                     .then((value) {
                                    //                   if (value == true) {
                                    //                     setState(() {
                                    //                       nearByCharityForReg =
                                    //                           getNearByCharityForReg(
                                    //                               selectedCountryID!);
                                    //                     });
                                    //                   }
                                    //                 });
                                    //               }
                                    //             },
                                    //             child: AutoSizeText(
                                    //               S.of(context).selectCharity,
                                    //               // 'Select Charity',
                                    //               style: TextStyle(
                                    //                   color: GlobalColors.gray
                                    //                       .withValues(alpha: 0.8),
                                    //                   fontSize: 15.sp,
                                    //                   fontWeight: FontWeight.w500),
                                    //             ),
                                    //           ),
                                    //         );
                                    //       } else {
                                    //         return Container(
                                    //           height: 50.h,
                                    //           width: double.infinity,
                                    //           decoration: BoxDecoration(
                                    //             color: GlobalColors.paleGray,
                                    //             borderRadius:
                                    //                 BorderRadius.circular(5.0),
                                    //           ),
                                    //           child: snapshot.data!.data!.isEmpty
                                    //               ? Padding(
                                    //                   padding: const EdgeInsets.only(
                                    //                       top: 15.0,
                                    //                       left: 25.0,
                                    //                       right: 25.0),
                                    //                   child: AutoSizeText(
                                    //                     S
                                    //                         .of(context)
                                    //                         .noCharityAvailable,
                                    //                     style: locationStyle.copyWith(
                                    //                         fontWeight:
                                    //                             FontWeight.w500),
                                    //                   ),
                                    //                 )
                                    //               : iscountryChanged == true
                                    //                   ? Padding(
                                    //                       padding:
                                    //                           const EdgeInsets.only(
                                    //                               top: 15,
                                    //                               left: 25,
                                    //                               right: 25),
                                    //                       child: AutoSizeText(
                                    //                         S.of(context).pleaseWait,
                                    //                         style: locationStyle
                                    //                             .copyWith(
                                    //                                 fontWeight:
                                    //                                     FontWeight
                                    //                                         .w500),
                                    //                       ),
                                    //                     )
                                    //                   : DropdownButtonWidget(
                                    //                       label: S
                                    //                           .of(context)
                                    //                           .selectCharity,
                                    //                       searchController:
                                    //                           stateSearchController,
                                    //                       isExpanded: true,
                                    //                       bWidth: double.infinity,
                                    //                       iHeight: 35,
                                    //                       dropHeight: 175,
                                    //                       searchHeight: 40,
                                    //                       items: snapshot.data!.data!
                                    //                           .map((e) {
                                    //                         return DropdownMenuItem(
                                    //                           value: e.charityName,
                                    //                           child: Padding(
                                    //                             padding:
                                    //                                 const EdgeInsets
                                    //                                     .only(
                                    //                               left: 25,
                                    //                               top: 0,
                                    //                               bottom: 0,
                                    //                             ),
                                    //                             child: AutoSizeText(
                                    //                               e.charityName!,
                                    //                               style:
                                    //                                   dopdownTextStyle,
                                    //                             ),
                                    //                           ),
                                    //                         );
                                    //                       }).toList(),
                                    //                       onChanged: (newVal) async {
                                    //                         setState(() {
                                    //                           selectedCharity =
                                    //                               newVal as String;
                                    //                         });
                                    //                         final charityIDD = snapshot
                                    //                             .data!.data!
                                    //                             .firstWhere((element) =>
                                    //                                 element
                                    //                                     .charityName ==
                                    //                                 selectedCharity);
                                    //                         selectedCharityID =
                                    //                             charityIDD.id;
                                    //                       },
                                    //                       value: selectedCharity,
                                    //                     ),
                                    //         );
                                    //       }
                                    //     }),

                                    const SizedBox(height: 15),
                                    // I agree with the Term and Condition
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Checkbox(
                                            checkColor: Colors.white,
                                            activeColor: _primaryBlue,
                                            side: const BorderSide(
                                                width: 2, color: _primaryBlue),
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: _primaryBlue,
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

                                    _gradientContinueButton(),
                                    SizedBox(height: 14.h),
                                    Text(
                                      'Secure verification required before activation',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            _softText.withValues(alpha: 0.85),
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
            height: 120,
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

  // Missing Issuer Code Confirmation Dialog
  missingIssuerConfirmationDialog() {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            // 1. REMOVED fixed height here
            width: MediaQuery.of(context).size.width / 1.1,
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            padding: const EdgeInsets.all(
                20.0), // Increased padding slightly for breathing room
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                // 2. ADDED MainAxisSize.min so it only takes exactly as much height as needed
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text
                  AutoSizeText(
                    infoMessage ?? '__',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: Colors.black,
                      fontFamily: 'Sans',
                    ),
                  ),
                  const SizedBox(
                      height: 20), // Spacing between text and buttons

                  // Buttons (Cancel & Continue)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: S.of(context).cancel,
                          onPressed: () {
                            context.pop(); // Dismiss dialog
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: S.of(context).continueL,
                          onPressed: () async {
                            context.pop(); // Dismiss dialog
                            setState(() {
                              isLoading = true;
                            });

                            // 1. Check if email/phone already exists
                            bool? validityResult = await checkEmailAndPhoneNo();

                            if (validityResult == false) {
                              // 2. Validate the premium code (with an empty issuer code)
                              var preRes = await DioRegister().premiumVal(
                                premiumValidityReqModel:
                                    PremiumValidityReqModel(
                                  memberPremiumCode: premiumController.text
                                      .trim()
                                      .toUpperCase(),
                                  issuerCode: providerController.text
                                      .trim(), // Empty because they continued without one
                                ),
                              );

                              if (!mounted) return;

                              if (preRes is CommonResModel) {
                                if (preRes.status == 'success') {
                                  // 3. Everything is valid, send the OTP!
                                  sendPhoneOtp();
                                } else {
                                  GlobalSnackBar.showError(
                                      context,
                                      preRes.message ??
                                          S.of(context).premiumCodeIsNotValid);
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              } else {
                                // Invalid premium code format/error
                                setState(() {
                                  isLoading = false;
                                });
                                invalidPremium();
                              }
                            } else {
                              // Email or Phone already exists
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
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
    if (premiumCodeInput == 'SAVER20' && providerController.text.isEmpty) {
      providerController.text = 'AU0000000001';
    }
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
