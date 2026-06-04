import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/not_available.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/charity/services/dio_charity.dart';
import 'package:touristsaver/features/profile/services/dio_membership.dart';
import 'package:touristsaver/features/profile/widget/info_popup.dart';
import 'package:touristsaver/models/request/nearby_req.dart';
import 'package:touristsaver/models/response/member_selected_charity_res_model.dart'
    as mmm;
//import 'package:touristsaver/models/response/get_charity_list_res.dart';
import 'package:touristsaver/models/response/nearby_charity_res.dart';
//   as nearby_ch;
import 'package:touristsaver/models/response/user_detail_res.dart';

import '../../../common/app_variables.dart';
import 'package:touristsaver/generated/l10n.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../constants/location_not_enable.dart';
import '../../../constants/pref.dart';
import '../../../constants/pref_key.dart';
import '../../../models/request/select_charity_req.dart';
import '../../../models/response/select_charity_res.dart';
import '../widgets/my_charity_widget.dart';

class CharityList extends StatefulWidget {
  static const String routeName = '/charity-list';
  const CharityList({super.key});

  @override
  State<CharityList> createState() => _CharityListState();
}

class _CharityListState extends State<CharityList> {
  // To retrieve the state id of user
  String? stateId;
  // selecting the charity
  int? clickedCharity;
  int? charitySelect;
  String? stateName;
  String? countryName;
  String? selectedCharityName;
  bool charityLoader = false;
  int? charityID;

  //Calling API of NearBy Charity
  Future<NearByCharityListResModel?>? nearbyResCharity;
  Future<NearByCharityListResModel?>? getNearByResCharity() async {
    String countryId = await Pref().readData(key: saveCountryID);
    NearByCharityListResModel? nearByCharityListResModel =
        await DioCharity().getNearByCharity(
      nearByLocationReqModel: NearByLocationReqModel(
        latitude: AppVariables.latitude,
        longitude: AppVariables.longitude,
        radius: 50,
        lang: AppVariables.selectedLanguageNow,
        countryId: int.parse(countryId),
      ),
    );
    return nearByCharityListResModel;
  }

  // To show the charity that is selected by the user
  Future<UserProfileResModel?>? userDetail;
  Future<UserProfileResModel?>? getUserDetail() async {
    UserProfileResModel? userProfileResModel =
        await DioMemberShip().getUserProfile();
    charitySelect = userProfileResModel!.data!.results!.charityId;
    stateId = 'null';
    stateName = userProfileResModel.data!.results!.state!.stateName;
    countryName = userProfileResModel.data!.results!.country!.countryName;
    return userProfileResModel;
  }

  //Calling API of GetAll Charity
  Future<mmm.MemberSelectedCharityResModel?>? getCharityByMem;
  Future<mmm.MemberSelectedCharityResModel?>? charityBymember() async {
    setState(() {
      charityLoader = true;
    });
    mmm.MemberSelectedCharityResModel? memberSelectedCharityResModel =
        await DioCharity().getCharityByMember();
    setState(() {
      selectedCharityName = memberSelectedCharityResModel?.data?.charityName;
      charityID = memberSelectedCharityResModel?.data?.id;
      charityLoader = false;
    });
    // log(memberSelectedCharityResModel!.toJson().toString());
    return memberSelectedCharityResModel;
  }

  // For the FloatingActionButton Loading part
  bool isLoading = false;

  //For page loading part
  // bool isCountryState = false;
  // List<Datum> allCharityListData = [];

  //For Error loadCharityList
  String? err;

  void loadCharityList() async {
    // if (!mounted) return;
    // setState(() {
    //   isCountryState = true;
    // });
    try {
      nearbyResCharity = getNearByResCharity();
      // final resCharityList =
      // await DioCharity().getNearByCharity(
      //   nearByLocationReqModel: NearByLocationReqModel(
      //     latitude: AppVariables.latitude,
      //     longitude: AppVariables.longitude,
      //     radius: 50,
      //     lang: AppVariables.selectedLanguageNow,
      //   ),
      // );
      //   await DioCharity().getCharityList(stateId: stateId!);
      // if (!mounted) return;
      // setState(() {
      //   // allCharityListData = resCharityList!.data!;
      //   // searchOperation(
      //   //   searchController.text.trim(),
      //   // );
      // });
    } catch (e) {
      if (kDebugMode) {
        err = S.of(context).somethingWentWrong;
      }
    }
    if (!mounted) return;
    setState(() {
      clickedCharity = null;
      //    isCountryState = false;
    });
  }

  //Search Section
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  // List<Datum> searchResult = [];

  @override
  void initState() {
    userDetail = getUserDetail();
    getCharityByMem = charityBymember();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar1(
          text: S.of(context).charity,
          icon: Icons.arrow_back_ios,
          onPressed: () {
            context.pop();
          },
          onInfoTap: () {
            charityInfo();
          },
        ),
      ),

      body: RefreshIndicator(
        color: GlobalColors.appColor,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            userDetail = getUserDetail();
            nearbyResCharity = getNearByResCharity();
            getCharityByMem = charityBymember();
          });
        },
        child: ValueListenableBuilder(
            valueListenable: AppVariables.locationEnabledStatus,
            builder: (context, value, child) {
              if (value > 1) {
                nearbyResCharity = getNearByResCharity();
              }
              //  log(value.toString());
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    value > 1
                        ? charityLoader
                            ? const CustomAllLoader1()
                            : MyCharityWidget(charityName: selectedCharityName)
                        : const SizedBox(),
                    FutureBuilder<UserProfileResModel?>(
                        future: userDetail,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Error1();
                          } else if (!snapshot.hasData) {
                            return const Column(
                              children: [
                                CustomAllLoader(),
                              ],
                            );
                          } else {
                            return Stack(
                              children: [
                                ScrollConfiguration(
                                  behavior: const ScrollBehavior(),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 100.0,
                                        top: 20.0,
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      //First checking the user profile for user selected charity and state id
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: AutoSizeText(
                                                  S.of(context).nearbyCharities,
                                                  style: TextStyle(
                                                    fontSize: 17.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  context.pushReplacementNamed(
                                                      'view-all-charity-list');
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: AutoSizeText(
                                                      S.of(context).viewAll,
                                                      style: profileListStyle
                                                          .copyWith(
                                                              color: GlobalColors
                                                                  .appColor1)),
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          // isCountryState
                                          //     ? const CustomAllLoader()
                                          //     :
                                          err ==
                                                  S
                                                      .of(context)
                                                      .somethingWentWrong
                                              ? const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 20.0),
                                                  child: Error(),
                                                )
                                              : AppVariables
                                                          .locationEnabledStatus
                                                          .value >
                                                      1
                                                  ? nearByCharityList()
                                                  : LocationNotEnabled(
                                                      text: S
                                                          .of(context)
                                                          .weWantToSetYourActualLocationToShowYouNearbyCharities)

                                          //noCharity(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // For fading the anything that is below the floating action button
                                // clickedCharity == null
                                //     ? const SizedBox()
                                //     : const FadeEndText(),
                              ],
                            );
                          }
                        }),
                  ],
                ),
              );
            }),
      ),

      // //  Apply Button
      // floatingActionButton: floatingButton(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  nearByCharityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<NearByCharityListResModel?>(
            future: nearbyResCharity,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Error();
              } else if (!snapshot.hasData) {
                return const CustomAllLoader();
              } else {
                int p3Index = snapshot.data!.data!
                    .indexWhere((item) => item.id == charityID);
                if (p3Index != -1) {
                  snapshot.data!.data!.removeAt(p3Index);
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemCount: snapshot.data!.data!.isEmpty
                      ? 1
                      : snapshot.data!.data!.length,
                  itemBuilder: (context, index) {
                    return snapshot.data!.data!.isEmpty
                        ? noCharity()
                        : Column(
                            children: [
                              //List
                              InkWell(
                                borderRadius: BorderRadius.circular(5.0),
                                onTap: () {
                                  setState(() {
                                    // selectCharityInfo();
                                    clickedCharity =
                                        snapshot.data!.data![index].id!;
                                    charitySelect =
                                        snapshot.data!.data![index].id!;
                                    applyCharityPopUp();
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  constraints: const BoxConstraints(
                                    //To make height expandable according to the text
                                    maxHeight: double.infinity,
                                  ),
                                  child: ListTile(
                                    tileColor:
                                        GlobalColors.appWhiteBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    title: Padding(
                                      padding: const EdgeInsets.only(bottom: 0),
                                      // Charity Name
                                      child: AutoSizeText(
                                        snapshot
                                            .data!.data![index].charityName!,
                                        style: profileListStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                  },
                );
              }
            }),
      ],
    );
  }

  // charity info
  charityInfo() {
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
          child: InfoPopUp(
            title: S.of(context).charity,
            body: S.of(context).partOfOurMission,
            footer: S.of(context).cashFromEachTransaction,
            image: 'assets/images/charity.png',
            onOk: () {
              context.pop();
            },
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

  applyCharityPopUp() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).chooseCharity,
                  textAlign: TextAlign.center,
                  style: topicStyle,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).cashFromEachTransaction,
                      textAlign: TextAlign.center,
                      style: dopdownTextStyle,
                    ),
                    Text(
                      S.of(context).areYouSureYouWantToChooseThisCharity,
                      textAlign: TextAlign.center,
                      style: dopdownTextStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Yes Button
                Row(
                  children: [
                    Expanded(
                      child: isLoading == true
                          ? const CustomButtonWithCircular()
                          : CustomButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                var res = await DioCharity().selectCharity(
                                    selectCharityReqModel:
                                        SelectCharityReqModel(
                                            charityId: charitySelect));
                                if (!mounted) return;
                                if (res is SelectCharityResModel) {
                                  setState(() {
                                    isLoading = false;
                                    clickedCharity = null;
                                  });
                                  context.pop();
                                  GlobalSnackBar.showSuccess(
                                      context, S.of(context).charityChanged);
                                  getCharityByMem = charityBymember();
                                  return;
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  context.pop();
                                  GlobalSnackBar.showError(context,
                                      S.of(context).somethingWentWrong);
                                  return;
                                }
                              },
                              text: S.of(context).apply,
                            ),
                    ),

                    const SizedBox(width: 10),

                    // No Button
                    Expanded(
                      child: CustomButton1(
                        onPressed: () {
                          context.pop();
                        },
                        text: S.of(context).cancel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // No Charity Available
  noCharity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotAvailable(
          titleText: S.of(context).noCharityAvailable,
          bodyText:
              S.of(context).currentlyThereAreNoCharitiesAvailableInYourLocation,
          image: 'assets/images/charity.png',
        ),
      ],
    );
  }

  // For Searching
  // searchOperation(String searchText) {
  //   searchResult.clear();
  //   if (searchText.isNotEmpty) {
  //     for (int i = 0; i < allCharityListData.length; i++) {
  //       List<Datum> data = allCharityListData;
  //       if (data[i]
  //           .charityName!
  //           .toLowerCase()
  //           .contains(searchText.toLowerCase())) {
  //         searchResult.add(data[i]);
  //       }
  //     }
  //   }
  // }
}
