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
import 'package:touristsaver/models/response/user_detail_res.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../models/request/select_charity_req.dart';
import '../../../models/response/get_all_charities.dart';
import 'package:touristsaver/generated/l10n.dart';

import '../../../models/response/member_selected_charity_res_model.dart'
    as mem_charity;
import '../../../models/response/select_charity_res.dart';
import '../widgets/my_charity_widget.dart';

class ViewAllCharityList extends StatefulWidget {
  static const String routeName = '/view-all-charity-list';
  const ViewAllCharityList({super.key});

  @override
  State<ViewAllCharityList> createState() => _ViewAllCharityListState();
}

class _ViewAllCharityListState extends State<ViewAllCharityList> {
  //Search Section
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  // List<Datum> searchResult = [];
  // To retrieve the state id of user
  String? stateId;
  // selecting the charity
  int? clickedCharity;
  int? charitySelect;
  String? stateName;
  String? countryName;
  bool viewAlll = true;
  // For the FloatingActionButton Loading part
  bool isLoading = false;
  //For page loading part
  bool isCountryState = false;
  // List<Datum> allCharityListData = [];
  //For Error loadCharityList
  String? err;
  bool charityLoader = false;
  String? selectedCharityName;
  int? charityID;
  String textBody = '';
  List arr = [];

  //Calling API of GetAll Charity
  Future<GetAllCharities?>? allResCharity;
  Future<GetAllCharities?>? getAllResCharity() async {
    // setState(() {
    //   isCountryState = true;
    // });
    GetAllCharities? getAllCharities =
        await DioCharity().getAllCharityList(searchController.text.trim());
    // setState(() {
    //   isCountryState = false;
    // });
    return getAllCharities;
  }

  // Future<void> getMemberCharity() async {
  //   // setState(() {
  //   //   charityLoader = true;
  //   // });
  //   mem_charity.MemberSelectedCharityResModel? memberSelectedCharityResModel =
  //       await DioCharity().getCharityByMember();
  //   selectedCharityName = memberSelectedCharityResModel?.data!.charityName;
  //   // setState(() {
  //   //   charityLoader = false;
  //   // });
  // }

  //Calling API of GetAll Charity
  Future<mem_charity.MemberSelectedCharityResModel?>? getCharityByMem;
  Future<mem_charity.MemberSelectedCharityResModel?>? charityBymember() async {
    setState(() {
      charityLoader = true;
    });
    mem_charity.MemberSelectedCharityResModel? memberSelectedCharityResModel =
        await DioCharity().getCharityByMember();
    setState(() {
      selectedCharityName = memberSelectedCharityResModel?.data?.charityName;
      charityID = memberSelectedCharityResModel?.data?.id;
      charityLoader = false;
    });
    return memberSelectedCharityResModel;
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

  void loadCharityList() async {
    // if (!mounted) return;
    // setState(() {
    //   isCountryState = true;
    // });
    try {
      allResCharity = getAllResCharity();
      // final resAllCharityList =
      //     await DioCharity().getAllCharityList(searchController.text.trim());
      // if (!mounted) return;
      // setState(() {
      //   allCharityListData = resAllCharityList!.data;
      //   searchOperation(
      //     searchController.text.trim(),
      //   );
      // });
    } catch (e) {
      if (kDebugMode) {
        err = S.of(context).somethingWentWrong;
      }
    }
    // if (!mounted) return;
    // setState(() {
    //   clickedCharity = null;
    //   isCountryState = false;
    // });
  }

  _ViewAllCharityListState() {
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {
          textBody = '';
          // isSearching = false;
          loadCharityList();
        });
      } else {
        setState(() {
          // isSearching = true;
          if (searchController.text.trim().length > 3) {
            loadCharityList();
            if (S.of(context).noCharityFoundForPleaseTryAgain.contains('&V.')) {
              textBody = S
                  .of(context)
                  .noCharityFoundForPleaseTryAgain
                  .replaceAll("&V.", "'${searchController.text.trim()}'.");
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    userDetail = getUserDetail();
    allResCharity = getAllResCharity();
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
          // icon: Icons.arrow_back_ios,
          // onPressed: () {
          //   context.pop();
          // },
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
            allResCharity = getAllResCharity();
            getCharityByMem = charityBymember();
          });
        },
        child: FutureBuilder<UserProfileResModel?>(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search For Charity within of country id
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.3,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          color: GlobalColors.appColor
                                              .withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.search,
                                          size: 30,
                                          color: GlobalColors.gray,
                                        ),
                                        const SizedBox(width: 5),
                                        // TextFormField
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            controller: searchController,
                                            cursorColor: GlobalColors.appColor,
                                            decoration:
                                                textInputDecoration.copyWith(
                                                    hintText: S
                                                        .of(context)
                                                        .searchWithinCountry,
                                                    //  'Search within country',
                                                    hintStyle: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400)),
                                            // onTap: () {
                                            //   setState(() {
                                            //     isSearching = true;
                                            //   });
                                            // },
                                            // onChanged: (value) {
                                            //   err = null;
                                            //   if (value.length >= 3) {
                                            //     loadCharityList();
                                            //   } else if (value.isEmpty) {
                                            //     setState(() {
                                            //       loadCharityList();

                                            //       // searchResult.clear();
                                            //       clickedCharity = null;
                                            //       err = null;
                                            //       stateId = 'null';
                                            //       FocusManager
                                            //           .instance.primaryFocus
                                            //           ?.unfocus();
                                            //       // allCharityListData.clear();
                                            //     });
                                            //   }
                                            // },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),
                                  // Cancel
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          // searchResult.clear();
                                          searchController.clear();
                                          clickedCharity = null;
                                          err = null;
                                          stateId = 'null';
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          // allCharityListData.clear();
                                        });
                                        loadCharityList();
                                      },
                                      child: AutoSizeText(S.of(context).clear,
                                          style: searchStyle.copyWith(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              charityLoader
                                  ? const Center(child: CustomAllLoader1())
                                  : MyCharityWidget(
                                      charityName: selectedCharityName),
                              const SizedBox(height: 10),
                              FittedBox(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: AutoSizeText(
                                          '${S.of(context).charityWithin} $countryName',
                                          style: profileListStyle.copyWith(
                                              color: Colors.grey)),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.pushReplacementNamed(
                                            'charity-list');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: AutoSizeText(
                                          S.of(context).viewNearby,
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w500,
                                            color: GlobalColors.appColor1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              allCharityList(),
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
      ),

      // //  Apply Button
      // floatingActionButton: floatingButton(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Loaded All State Charity
  allCharityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<GetAllCharities?>(
            future: allResCharity,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Error();
              } else if (!snapshot.hasData) {
                return const CustomAllLoader();
              } else {
                int p3Index = snapshot.data!.data
                    .indexWhere((item) => item.id == charityID);
                if (p3Index != -1) {
                  snapshot.data!.data.removeAt(p3Index);
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemCount: snapshot.data!.data.isEmpty
                      ? 1
                      : snapshot.data!.data.length,
                  itemBuilder: (context, index) {
                    return snapshot.data!.data.isEmpty
                        ? noCharity()
                        : Column(
                            children: [
                              //List
                              InkWell(
                                borderRadius: BorderRadius.circular(5.0),
                                onTap: () {
                                  setState(() {
                                    // selectCharityInfo();
                                    // getCharityByMem = charityBymember();
                                    clickedCharity =
                                        snapshot.data!.data[index].id;
                                    charitySelect =
                                        snapshot.data!.data[index].id;
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
                                        snapshot.data!.data[index].charityName,
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
                  S.of(context).selectCharity,
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
                                  searchController.clear();
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
                                  allResCharity = getAllResCharity();
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
          bodyText: textBody.toString(),
          image: 'assets/images/charity.png',
        ),
      ],
    );
  }
  // Floating Action Button
  // floatingButton() {
  //   return clickedCharity == null
  //       ? const SizedBox()
  //       : isLoading == true
  //           ? Container(
  //               width: MediaQuery.of(context).size.width / 1.2,
  //               height: 45.h,
  //               margin: const EdgeInsets.only(bottom: 30),
  //               child: FloatingActionButton.extended(
  //                 elevation: 2,
  //                 backgroundColor: GlobalColors.appColor1,
  //                 shape: const BeveledRectangleBorder(
  //                     borderRadius: BorderRadius.all(Radius.circular(2.0))),
  //                 onPressed: () {},
  //                 heroTag: const Text("btn2"),
  //                 label: const CircularProgressIndicator(
  //                   color: Colors.white,
  //                   strokeWidth: 3,
  //                 ),
  //               ),
  //             )
  //           : Container(
  //               width: MediaQuery.of(context).size.width / 1.2,
  //               height: 45.h,
  //               margin: const EdgeInsets.only(bottom: 30),
  //               child: FloatingActionButton.extended(
  //                 elevation: 2,
  //                 backgroundColor: GlobalColors.appColor1,
  //                 shape: const BeveledRectangleBorder(
  //                     borderRadius: BorderRadius.all(Radius.circular(2.0))),
  // onPressed: () async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   var res = await DioCharity().selectCharity(
  //       selectCharityReqModel:
  //           SelectCharityReqModel(charityId: charitySelect));
  //   if (!mounted) return;
  //   if (res is SelectCharityResModel) {
  //     setState(() {
  //       // getMemberCharity();
  //       getCharityByMem = charityBymember();
  //       isLoading = false;
  //       clickedCharity = null;
  //     });
  //     GlobalSnackBar.showSuccess(
  //         context, S.of(context).charityChanged);
  //     return;
  //   } else {
  //     GlobalSnackBar.showError(
  //         context, S.of(context).somethingWentWrong);
  //     setState(() {
  //       isLoading = false;
  //     });
  //     return;
  //   }
  // },
  //                 heroTag: const Text("btn2"),
  //                 label: AutoSizeText(
  //                   S.of(context).apply,
  //                   style: buttonText,
  //                 ),
  //               ),
  //             );
  // }
}
