import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/services/dio_common.dart';
import 'package:touristsaver/constants/env.dart';
import 'package:touristsaver/constants/initialize_stripe.dart';
import 'package:touristsaver/constants/read_sms_otp.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/location/bloc/location_all_blocs.dart';
import 'package:touristsaver/features/location/bloc/location_all_events.dart';
import 'package:touristsaver/features/location/bloc/location_all_states.dart';
import 'package:touristsaver/features/location/services/dio_location.dart';
import 'package:touristsaver/features/profile/services/dio_membership.dart';
import 'package:touristsaver/features/profile/services/dio_profile.dart';
import 'package:touristsaver/features/top_up/services/top_up_dio.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/change_country_req.dart';
import 'package:touristsaver/models/request/confirm_topup_req.dart';
import 'package:touristsaver/models/request/top_up_stripe_req.dart';
import 'package:touristsaver/models/response/change_country_res.dart';
import 'package:touristsaver/models/response/confirm_topup_res.dart';
import 'package:touristsaver/models/response/location_get_all.dart';
import 'package:touristsaver/models/response/member_package_res.dart';
import 'package:touristsaver/models/response/state_get_all.dart' as states;
import 'package:touristsaver/models/response/stripe_key_res.dart';
import 'package:touristsaver/models/response/top_up_stripe_res.dart';
import 'package:touristsaver/models/response/user_detail_res.dart';

import '../../../common/widgets/dropdown_button_widget.dart';
import '../../../models/response/common_res.dart';
import '../../../models/response/country_wise_prefix_res_model.dart';
import 'package:touristsaver/generated/l10n.dart';

const Color _changeCountryNavy = Color(0xFF111C44);
const Color _changeCountryBrandBlue = Color(0xFF0009FE);
const Color _changeCountryBrandPurple = Color(0xFFF146EA);

class ChangeCountry extends StatefulWidget {
  static const String routeName = '/change-country';
  const ChangeCountry({super.key});

  @override
  State<ChangeCountry> createState() => _ChangeCountryState();
}

class _ChangeCountryState extends State<ChangeCountry> {
  final TextEditingController countrySearchController = TextEditingController();
  final TextEditingController stateSearchController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController phonePrefixSearchController =
      TextEditingController();

  // For dropDown of selecting country
  String? selectedCountry;
  int? selectedCountryID;
  String? selectedPhonePrefix;

  String? selectedNumber;

  // For dropDown of selecting state
  String? selectedState;
  int? selectedStateID;
  Future<states.StateGetAllResModel?>? stateList;
  Future<states.StateGetAllResModel?> getState() async {
    states.StateGetAllResModel? stateGetAllResModel = await DioLocation()
        .getAllState(
            countryID: selectedCountryID ??
                int.parse(await Pref().readData(key: saveCountryID)));
    setState(() {
      iscountryChanged = false;
    });
    return stateGetAllResModel;
  }

  // //For email argument
  // String? email;

  // For filling the edit form of country and state
  Future<UserProfileResModel?>? fillUserEditForm;
  Future<UserProfileResModel?> fillEditForm() async {
    UserProfileResModel? userProfileResModel =
        await DioMemberShip().getUserProfile();
    selectedCountry = userProfileResModel!.data!.results!.country!.countryName;
    selectedCountryID = userProfileResModel.data!.results!.countryId;
    selectedState = userProfileResModel.data!.results!.state!.stateName;
    selectedStateID = userProfileResModel.data!.results!.stateId;
    mobileNumberController.text =
        userProfileResModel.data!.results!.phoneNumber!;
    selectedNumber = userProfileResModel.data!.results!.phoneNumberPrefix;
    return userProfileResModel;
  }

  // For Loading part
  bool isLoading = false;
  bool isLoadingB = false; //For Buy Piink Pop Up

  //For stopping selection of state when country is changed
  bool iscountryChanged = false;

  // Future<CountryWisePrefixResModel?>? phonePrefixList;
  // Future<CountryWisePrefixResModel?> getPhonePrefix() async {
  //   CountryWisePrefixResModel? countryWisePrefixResModel =
  //       await DioRegister().countryPhonePrefix();
  //   return countryWisePrefixResModel;
  // }

  @override
  void initState() {
    fillUserEditForm = fillEditForm();
    stateList = getState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).changeCountry,
          icon: Icons.arrow_back_ios,
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: BlocProvider(
        lazy: false,
        create: (context) =>
            LocationAllBloc(RepositoryProvider.of<DioLocation>(context))
              ..add(LoadLocationAllEvent()),
        child: BlocBuilder<LocationAllBloc, LocationAllState>(
            builder: (context, locationState) {
          // Loading State
          if (locationState is LocationAllLoadingState) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAllLoader(),
              ],
            );
          }
          // Loaded State
          else if (locationState is LocationAllLoadedState) {
            LocationGetAllResModel locationList =
                locationState.locationGetAll; //Location

            CountryWisePrefixResModel phonePrefixList =
                locationState.countryWisePrefixResModel; //phonePrefix
            return FutureBuilder<UserProfileResModel?>(
              future: fillUserEditForm,
              builder: (context, snapshot) {
                if (snapshot.data?.data?.results?.isEmailVerified == false) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                      decoration: BoxDecoration(
                          color: GlobalColors.appWhiteBackgroundColor,
                          borderRadius: BorderRadius.circular(22.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            )
                          ]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _changeCountryBrandBlue.withValues(
                                      alpha: 0.12),
                                  _changeCountryBrandPurple.withValues(
                                      alpha: 0.12),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/images/mail.png",
                                height: 78.h,
                                width: 78.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AutoSizeText(
                            'Verify Email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _changeCountryNavy,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          AutoSizeText(
                            'Please verify your email before changing your country settings.',
                            textAlign: TextAlign.center,
                            style: textStyle15h.copyWith(
                              color: Colors.black.withValues(alpha: 0.62),
                              fontSize: 15.sp,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AutoSizeText(
                            'Verification helps protect your account and access across regions.',
                            textAlign: TextAlign.center,
                            style: textStyle15h.copyWith(
                              color: GlobalColors.gray.withValues(alpha: 0.72),
                              fontSize: 13.sp,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _VerifyEmailPrimaryButton(
                            text: 'Verify Now',
                            isLoading: isLoading,
                            onPressed: () async {
                              if (isLoading) return;
                              setState(() {
                                isLoading = true;
                              });
                              var result = await DioProfile().verifyEmail();
                              if (!mounted) return;
                              if (result is CommonResModel) {
                                // ignore: use_build_context_synchronously
                                context.pop();
                                if (result.status == 'Success') {
                                  GlobalSnackBar.showSuccess(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      result.message ??
                                          S
                                              // ignore: use_build_context_synchronously
                                              .of(context)
                                              .verificationLinkSentSuccessfully);
                                }
                              } else if (result is ErrorResModel) {
                                setState(() {
                                  isLoading = false;
                                });
                                GlobalSnackBar.showError(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    result.message ??
                                        // ignore: use_build_context_synchronously
                                        S.of(context).someErrorOccurred);
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                // ignore: use_build_context_synchronously
                                GlobalSnackBar.showError(
                                    context,
                                    // ignore: use_build_context_synchronously
                                    S.of(context).someErrorOccurred);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Error1();
                } else if (!snapshot.hasData) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAllLoader(),
                    ],
                  );
                } else {
                  return Container(
                    margin: const EdgeInsets.all(10.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 20.0),
                    width: MediaQuery.of(context).size.width / 1,
                    height: 300,
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
                        // Select Country
                        selectCountry(locationList),
                        const SizedBox(height: 15),

                        // Select State
                        selectState(),

                        const SizedBox(height: 15),
                        // Mobile Number
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 55.h,
                                  child: DropdownButtonWidget(
                                    label: S.of(context).prefix,
                                    dropWidth: 140.w,
                                    lPadding: 3,
                                    searchController:
                                        phonePrefixSearchController,
                                    items: phonePrefixList.data!.map((e) {
                                      if (selectedNumber == e.phonePrefix) {
                                        selectedPhonePrefix = e.phonePrefix;
                                      }
                                      return DropdownMenuItem(
                                        value: e.phonePrefix,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Row(
                                            children: [
                                              Image.network(
                                                e.logoUrl ??
                                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/No_flag.svg/1024px-No_flag.svg.png',
                                                height: 20,
                                                width: 20,
                                              ),
                                              const SizedBox(
                                                width: 5.0,
                                              ),
                                              AutoSizeText(
                                                e.phonePrefix!,
                                                style: dopdownTextStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newVal) async {
                                      setState(() {
                                        // selectedPhonePrefix = newVal as String;
                                        selectedNumber = newVal as String;
                                        phonePrefixSearchController.clear();
                                      });
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
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.2,
                                  child: TextFormField(
                                    controller: mobileNumberController,
                                    cursorColor: GlobalColors.appColor,
                                    keyboardType: TextInputType.number,
                                    decoration: textInputDecoration1.copyWith(
                                        labelText: S.of(context).mobileNumber),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]*'))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width / 1.2,
                        //   child: TextFormField(
                        //     controller: mobileNumberController,
                        //     cursorColor: GlobalColors.appColor,
                        //     keyboardType: TextInputType.phone,
                        //     decoration: textInputDecoration2.copyWith(
                        //         labelText: 'Mobile Number *'),
                        //   ),
                        // ),

                        const SizedBox(height: 14),

                        // Update or Change Button
                        isLoading == true
                            ? const CustomButtonWithCircular()
                            : CustomButton(
                                text: S.of(context).update,
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
                                  }

                                  if (selectedState == null) {
                                    GlobalSnackBar.valid(
                                        context, S.of(context).selectTheState);
                                    setState(() {
                                      isLoading = false;
                                    });
                                    return;
                                  }

                                  if (selectedPhonePrefix == null) {
                                    GlobalSnackBar.valid(context,
                                        S.of(context).selectThePhonePrefix);
                                    setState(() {
                                      isLoading = false;
                                    });
                                    return;
                                  }

                                  if (mobileNumberController.text.isEmpty) {
                                    GlobalSnackBar.valid(context,
                                        S.of(context).pleaseEnterMobileNumber);
                                    setState(() {
                                      isLoading = false;
                                    });
                                    return;
                                  }

                                  FocusManager.instance.primaryFocus?.unfocus();

                                  var res = await DioProfile().changeCoun(
                                    changeCountryReqModel:
                                        ChangeCountryReqModel(
                                      countryId: selectedCountryID!,
                                      stateId: selectedStateID!,
                                      phoneNumberPrefix: selectedPhonePrefix!,
                                      phoneNumber:
                                          mobileNumberController.text.trim(),
                                      appSign: getAsign,
                                    ),
                                  );

                                  if (res is ChangeCountryResModel) {
                                    if (res.status == 'success') {
                                      // Saving Country ID after user changes their country
                                      Pref().writeData(
                                          key: saveCountryID,
                                          value:
                                              res.member!.countryId.toString());

                                      // Calling the location get all Api for saving the user member country currency symbol
                                      LocationGetAllResModel? countryCurrency =
                                          await DioLocation().getCurrency();

                                      Pref().writeData(
                                          key: saveCurrency,
                                          value: countryCurrency!
                                              .data![0].currencySymbol!);

                                      // Reading the saved country currency right after the writing when changing country
                                      AppVariables.currency = await Pref()
                                          .readData(key: saveCurrency);

                                      //Calling API to fetch the stripe key
                                      StripeKeyResModel? getStripeKey =
                                          await DioCommon().getStripe();
                                      if (getStripeKey is StripeKeyResModel) {
                                        Pref().writeData(
                                            key: savePublishableKey,
                                            value: getStripeKey.data!
                                                    .stripePublishableKey ??
                                                stripePublishableKey);
                                        initializeFlutterStripe();
                                      } else {
                                        if (!mounted) return;
                                        GlobalSnackBar.showError(
                                            context,
                                            S
                                                .of(context)
                                                .somethingWentWrongCouldnTFetchTheStripeKeyWhenChangingCountry);
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }

                                      // Removing the {userChosenLocationID, userChosenLocationStateID, userChosenLocationRegionID, userChosenLocationName} after successful change of the country
                                      Pref().removeData(userChosenLocationName);
                                      Pref().removeData(userChosenLocationID);
                                      // Pref().removeData(
                                      //     userChosenLocationStateID);
                                      Pref().removeData(
                                          userChosenLocationRegionID);

                                      // Now writing {userChosenLocationID, userChosenLocationName} from the response of getCurrency() API
                                      Pref().writeData(
                                          key: userChosenLocationName,
                                          value: countryCurrency
                                              .data![0].countryName!);
                                      //Saving Sountry Or State name for showing location of merchant
                                      Pref().writeData(
                                          key: userChosenCountryStateName,
                                          value: selectedState.toString());

                                      Pref().writeData(
                                          key: userChosenLocationID,
                                          value: countryCurrency.data![0].id
                                              .toString());
                                      Pref().writeData(
                                          key: userChosenLocationStateID,
                                          value: selectedStateID.toString());

                                      // Checking the condition for futher process
                                      if (!mounted) return;
                                      if (res.smsotpRequired == true) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        context.pushNamed('country-number-edit',
                                            extra: {
                                              'phonePrefix':
                                                  selectedPhonePrefix,
                                              'mobileNumber':
                                                  mobileNumberController.text
                                                      .trim(),
                                              'email': res.member!.email,
                                              'countryId':
                                                  res.member!.countryId!,
                                            });
                                      } else if (res.member!.countryId ==
                                          int.parse(
                                              AppVariables.originCountryId!)) {
                                        context.pushReplacementNamed(
                                            'bottom-bar',
                                            pathParameters: {'page': '3'});

                                        GlobalSnackBar.showSuccess(
                                            context,
                                            S
                                                .of(context)
                                                .countryChangedSuccessfully);
                                      } else {
                                        buyPiinkPopUp();
                                        GlobalSnackBar.showSuccess(
                                            context,
                                            S
                                                .of(context)
                                                .countryChangedSuccessfully);
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  } else if (res is ErrorResModel) {
                                    if (!mounted) return;
                                    GlobalSnackBar.showError(
                                        context,
                                        res.message ??
                                            S.of(context).somethingWentWrong);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } else {
                                    if (!mounted) return;
                                    GlobalSnackBar.showError(context,
                                        S.of(context).somethingWentWrong);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                              )
                      ],
                    ),
                  );
                }
              },
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
        }),
      ),
    );
  }

  // Selecting or Changing the Country
  selectCountry(LocationGetAllResModel locationList) {
    return DropdownButtonWidget(
      label: S.of(context).selectCountryA,
      searchController: countrySearchController,
      items: locationList.data!.map((e) {
        return DropdownMenuItem(
          value: e.countryName,
          child: Padding(
            padding: const EdgeInsets.only(left: 25),
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
          selectedState = null;
          iscountryChanged = true;
        });
        final locationID = locationList.data!
            .firstWhere((element) => element.countryName == selectedCountry);
        selectedCountryID = locationID.id!;
        //  selectedPhonePrefix = locationID.phonePrefix!;
        //calling the state api
        setState(() {
          stateList = getState();
        });
      },
      value: selectedCountry,
    );
  }

  // Selecting or Changing the state
  selectState() {
    return FutureBuilder<states.StateGetAllResModel?>(
        future: stateList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              padding:
                  const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
              height: 50,
              width: MediaQuery.of(context).size.width / 1.2,
              decoration: BoxDecoration(
                color: GlobalColors.paleGray,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: AutoSizeText(
                S.of(context).error,
                style: TextStyle(
                    color: GlobalColors.gray.withValues(alpha: 0.8),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500),
              ),
            );
          } else if (!snapshot.hasData) {
            return Container(
              padding:
                  const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
              height: 50,
              width: MediaQuery.of(context).size.width / 1.2,
              decoration: BoxDecoration(
                color: GlobalColors.paleGray,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: AutoSizeText(
                S.of(context).selectStateProvince,
                style: TextStyle(
                    color: GlobalColors.gray.withValues(alpha: 0.8),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500),
              ),
            );
          } else {
            return Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 1.2,
              decoration: BoxDecoration(
                color: GlobalColors.paleGray,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: snapshot.data!.data!.isEmpty
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 25, right: 25),
                      child: AutoSizeText(
                        S.of(context).noStateAvailable,
                        style:
                            locationStyle.copyWith(fontWeight: FontWeight.w500),
                      ),
                    )
                  : iscountryChanged == true
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: 15, left: 25, right: 25),
                          child: AutoSizeText(
                            S.of(context).pleaseWait,
                            style: locationStyle.copyWith(
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      : DropdownButtonWidget(
                          label: S.of(context).selectStateProvince,
                          searchController: stateSearchController,
                          items: snapshot.data!.data!.map((e) {
                            return DropdownMenuItem(
                              value: e.stateName,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: AutoSizeText(
                                  e.stateName!,
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
                                (element) =>
                                    element.stateName == selectedState);
                            selectedStateID = stateID.id;
                          },
                          value: selectedState,
                        ),
            );
          }
        });
  }

  // After Successfully change of the country
  buyPiinkPopUp() async {
    // Reading the saved country currency right after the writing when changing country
    String countryID = await Pref().readData(key: saveCountryID);
    // print("countryID");
    // print(countryID);
    if (!mounted) return;
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: false, //to dismiss the container once opened
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Container(
              // height: 520,
              width: MediaQuery.of(context).size.width / 1.1,
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // Grey Line
                  Container(
                    width: 65,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(50)),
                  ),

                  const SizedBox(height: 20),

                  // title Text
                  AutoSizeText(
                    S.of(context).touristSaverCreditsInfo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        decoration: TextDecoration.none,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontFamily: 'Sans'),
                  ),

                  const SizedBox(height: 15),

                  // Body Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: AutoSizeText(
                      S
                          .of(context)
                          .topUpUniversalTouristSaverCreditsToGetDiscountWithAnyOfOurMerchant,
                      textAlign: TextAlign.center,
                      style: transactionTextStyle.copyWith(
                        color: Colors.black.withValues(alpha: 0.7),
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Image
                  SizedBox(
                    // color: Colors.orange,
                    child: Image.asset(
                      "assets/images/shopping-bag.png",
                      height: 130,
                      width: MediaQuery.of(context).size.width / 2,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Top Up Button
                  StatefulBuilder(builder: (context, stateMod) {
                    return FutureBuilder<MemberShipPackageResModel?>(
                        future: DioTopUpStripe().memPack(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CustomButton(text: S.of(context).pleaseWait);
                          } else {
                            var memPackAll = snapshot.data!;
                            return memPackAll.data!.isEmpty
                                ? CustomButton(
                                    text: S.of(context).noTopUpAvailable,
                                    onPressed: () {
                                      // Navigator.pushAndRemoveUntil(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             const BottomBar()),
                                      //     ((route) => false));
                                      // GlobalSnackBar.showSuccess(
                                      //     context, 'Country Changed Successfully');
                                    },
                                  )
                                : isLoadingB == true
                                    ? const CustomButtonWithCircular()
                                    : CustomButton(
                                        text: S
                                            .of(context)
                                            .topUpAndPayXY
                                            .replaceAll('&XY',
                                                '${AppVariables.currency}${memPackAll.data![0].packageFee.toString()} inc GST'),
                                        onPressed: () async {
                                          stateMod(() {
                                            isLoadingB = true;
                                          });
                                          var res = await DioTopUpStripe()
                                              .topUpStripe(
                                            topUpStripeReqModel:
                                                TopUpStripeReqModel(
                                                    paymentGateway: 'stripe',
                                                    membershipPackageId:
                                                        memPackAll.data![0].id
                                                            .toString(),
                                                    countryId: countryID),
                                          );
                                          if (!mounted) return;
                                          if (res is TopUpStripeResModel) {
                                            await Stripe.instance
                                                .initPaymentSheet(
                                                    paymentSheetParameters:
                                                        SetupPaymentSheetParameters(
                                              paymentIntentClientSecret:
                                                  res.clientSecret,
                                              // applePay: const PaymentSheetApplePay(
                                              //     merchantCountryCode: 'DE'),
                                              // googlePay: const PaymentSheetGooglePay(
                                              //     merchantCountryCode: 'DE', testEnv: true),
                                              merchantDisplayName: 'Prospects',
                                              style: ThemeMode.dark,
                                              // returnURL:
                                              //     'https://piiink-backend.demo-4u.net/api/$stripePayConfirm',
                                            ));
                                            stateMod(() {
                                              isLoadingB = false;
                                            });
                                            await displayPaymentSheet(
                                                res.clientSecret);
                                          } else {
                                            GlobalSnackBar.showError(context,
                                                S.of(context).serverError);
                                            stateMod(() {
                                              isLoadingB = false;
                                            });
                                          }
                                        },
                                      );
                          }
                        });
                  }),

                  const SizedBox(height: 20),

                  // Free Button
                  CustomButton(
                    text: S.of(context).continueWithDefaultTouristSaverCredits,
                    onPressed: () {
                      if (!mounted) return;
                      context.pushReplacementNamed('bottom-bar',
                          pathParameters: {'page': '3'});
                      GlobalSnackBar.showSuccess(
                          context, S.of(context).countryChangedSuccessfully);
                    },
                  ),
                  const SizedBox(height: 15),
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

  // For Top Up
  Future<void> displayPaymentSheet(String? clientSecret) async {
    try {
      //this shows the stripe pay form
      await Stripe.instance.presentPaymentSheet().then((value) async {
        //Retreiving the response after stripe sheet pay button is clicked

        var res = await Stripe.instance.retrievePaymentIntent(clientSecret!);
        if (res.status == PaymentIntentsStatus.Succeeded) {
          // Confirming the stripe payment in backend
          var confirm = await DioTopUpStripe().confirmTopUp(
              confirmTopUpReqModel: ConfirmTopUpReqModel(
                  paymentIntent: res.id,
                  paymentIntentClientSecret: res.clientSecret));
          if (!mounted) return;
          if (confirm is ConfirmTopUpResModel) {
            if (confirm.status == 'success') {
              // Navigating
              context.pushReplacementNamed('bottom-bar',
                  pathParameters: {'page': '3'});
              // Message
              GlobalSnackBar.showSuccess(
                  context, S.of(context).paymentSuccessful);
            } else {
              GlobalSnackBar.showError(context, S.of(context).paymentFailed);
            }
          } else {
            GlobalSnackBar.showError(context, S.of(context).serverError);
          }
        } else {
          if (!mounted) return;
          GlobalSnackBar.showError(context, S.of(context).stripePaymentFail);
        }
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        var res = await Stripe.instance.retrievePaymentIntent(clientSecret!);
        // print(res);

        // Confirming the stripe payment in backend
        var confirm = await DioTopUpStripe().confirmTopUp(
            confirmTopUpReqModel: ConfirmTopUpReqModel(
                paymentIntent: res.id,
                paymentIntentClientSecret: res.clientSecret));
        if (!mounted) return;
        if (confirm is ConfirmTopUpResModel) {
          if (confirm.status == 'failed') {
            GlobalSnackBar.showError(context, S.of(context).paymentFailed);
          } else {
            GlobalSnackBar.showError(context, S.of(context).paymentFailed);
          }
        } else {
          GlobalSnackBar.showError(
              context, S.of(context).thePaymentHasBeenCanceled);
        }
        // print("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        // print("Unforeseen error: ${e}");
        return;
      }
    } catch (e) {
      // print("exception:$e");
      return;
    }
  }
}

class _VerifyEmailPrimaryButton extends StatelessWidget {
  const _VerifyEmailPrimaryButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
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
          height: 50.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _changeCountryBrandBlue,
                _changeCountryBrandPurple,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _changeCountryBrandBlue.withValues(alpha: 0.18),
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
                : AutoSizeText(
                    text,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
