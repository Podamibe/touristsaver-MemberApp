// ignore_for_file: deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/no_merchant.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/home_page/services/home_dio.dart';

import '../../../common/services/location_service.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/custom_loader.dart';
import '../../../common/widgets/dropdown_button_widget.dart';
import '../../../models/response/location_merchants_res_model.dart';
import '../../../models/response/cat_model.dart';
import 'package:touristsaver/generated/l10n.dart';

class LocationSearchMerchant extends StatefulWidget {
  static const String routeName = '/location-search-merchant';
  const LocationSearchMerchant({super.key});

  @override
  State<LocationSearchMerchant> createState() => _LocationSearchMerchantState();
}

class _LocationSearchMerchantState extends State<LocationSearchMerchant> {
  //For Search
  final TextEditingController searchController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final searchKey = GlobalKey<FormState>();

  bool isSearching = false;

  //For page Loading part
  bool isSearchedChanged = false;
  String? err;

  List<Merchant> allSearchedMer = [];
  bool recallMerchantApi = false;
  bool locationPinClicked = false;
  String? selectedCategory;
  String? selectedCategoryItem;
  int? selectedCategoryId;
  bool searchClicked = false;

  bool isButtonTapped = false;
  bool isButtonTapped1 = false;

  loadSearchedList(String location, int? categoryId) async {
    if (!mounted) return;
    setState(() {
      isSearchedChanged = true;
    });
    try {
      final resSearchedList = await DioHome()
          .getLocationMerchants(location: location, categoryId: categoryId);
      if (!mounted) return;
      setState(() {
        allSearchedMer = resSearchedList!.merchants!;
      });
    } catch (e) {
      if (kDebugMode) {
        err = 'Something went wrong';
      }
    }
    setState(() {
      if (!mounted) return;
      isSearchedChanged = false;
    });
  }

  Future<MemberCategoryResModel?>? catLis;
  Future<MemberCategoryResModel?> catRez() async {
    MemberCategoryResModel? memberCategoryResModel =
        await DioHome().getMemberCategory();

    return memberCategoryResModel;
  }

  @override
  void initState() {
    catLis = catRez();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          context.pop(recallMerchantApi);
          return true;
        },
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: CustomAppBar(
                  text: S.of(context).searchByLocationCategory,
                  icon: Icons.arrow_back_ios,
                  onPressed: () {
                    context.pop(recallMerchantApi);
                  },
                )),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120.h,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: GlobalColors.appWhiteBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 9,
                              child: Column(
                                children: [
                                  appBarSearch(),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  FutureBuilder<MemberCategoryResModel?>(
                                      future: catLis,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Container(
                                            padding: const EdgeInsets.only(
                                                left: 25, right: 25, top: 15),
                                            height: 35.h,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: GlobalColors.paleGray,
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: AutoSizeText(
                                              S.of(context).error,
                                              style: TextStyle(
                                                  color: GlobalColors.gray
                                                      .withValues(alpha: 0.8),
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          );
                                        } else if (!snapshot.hasData) {
                                          return Container(
                                            padding: const EdgeInsets.only(
                                                left: 25, right: 25, top: 15),
                                            height: 35.h,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: GlobalColors.paleGray,
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: AutoSizeText(
                                              S.of(context).pleaseWait,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: GlobalColors.gray
                                                      .withValues(alpha: 0.8),
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            height: 35.h,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: GlobalColors.paleGray,
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: snapshot.data!.data!.isEmpty
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0,
                                                            left: 25.0,
                                                            right: 25.0),
                                                    child: AutoSizeText(
                                                      S
                                                          .of(context)
                                                          .noCategoryFound,
                                                      //          'No Category Available',
                                                      style: locationStyle
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  )
                                                : Container(
                                                    height: 35.h,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            GlobalColors
                                                                .appColor,
                                                            GlobalColors
                                                                .appColor1
                                                          ],
                                                          begin: Alignment
                                                              .topRight,
                                                          end: Alignment
                                                              .bottomLeft,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: DropdownButtonWidget(
                                                      label: S
                                                          .of(context)
                                                          .selectCategory,
                                                      dropWidth: 235,
                                                      lPadding: 10,
                                                      searchController:
                                                          categoryController,
                                                      items: snapshot
                                                          .data!.data!
                                                          .map((e) {
                                                        return DropdownMenuItem(
                                                          value: e.name,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 15),
                                                            child: Text(
                                                              e.name.toString(),
                                                              style:
                                                                  dopdownTextStyle,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (newVal) async {
                                                        setState(() {
                                                          selectedCategory =
                                                              newVal as String;
                                                        });
                                                        final smsID = snapshot
                                                            .data!.data!
                                                            .firstWhere((element) =>
                                                                element.name ==
                                                                selectedCategory);
                                                        selectedCategoryId =
                                                            smsID.id;
                                                      },
                                                      value: selectedCategory,
                                                    ),
                                                  ),
                                            // ),
                                          );
                                        }
                                      }),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  if (searchController.text.trim().isEmpty &&
                                      selectedCategory == null) {
                                    GlobalSnackBar.valid(
                                        context,
                                        S
                                            .of(context)
                                            .pleaseSearchByLocationOrSelectCategory
                                        // 'Please search by location or select category'
                                        );
                                    return;
                                  }
                                  searchClicked = true;
                                  loadSearchedList(searchController.text.trim(),
                                      selectedCategoryId);
                                },
                                child: const Icon(Icons.search,
                                    size: 30, color: GlobalColors.appColor1),
                              ),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    searchClicked = false;
                                    isSearching = false;
                                    searchController.clear();
                                    err = null;
                                    allSearchedMer.clear();
                                    selectedCategoryId = null;
                                    selectedCategory = null;
                                  });
                                },
                                child: const Icon(Icons.clear_sharp,
                                    size: 30, color: GlobalColors.appColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Center(
                          child: Text(
                        S.of(context).or,
                        //      'OR',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                      SizedBox(
                        height: 10.h,
                      ),
                      IgnorePointer(
                        ignoring: isButtonTapped,
                        child: TextButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              isButtonTapped = true;
                              searchClicked = false;
                              isSearching = false;
                              searchController.clear();
                              err = null;
                              allSearchedMer.clear();
                              selectedCategoryId = null;
                              selectedCategory = null;
                            });
                            LocationService()
                                .enableLocationAndFetchCountry()
                                .then((value) {
                              if (value == true) {
                                context.pushNamed('choose-on-map',
                                    pathParameters: {
                                      'appBarName': 'Near Me'
                                    }).then((value) {
                                  setState(() {
                                    isButtonTapped = false;
                                  });
                                  if (AppVariables.locationEnabledStatus.value >
                                          1 &&
                                      value == true) {
                                    AppVariables.locationEnabledStatus.value +=
                                        1;
                                  }
                                });
                              } else if (value == false) {
                                setState(() {
                                  isButtonTapped = false;
                                });
                              }
                            });
                          },
                          child: isButtonTapped == true
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GlobalColors.loaderColor)
                              : Row(
                                  children: [
                                    const Icon(
                                      Icons.directions,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      S.of(context).nearMe,
                                      //     'Near Me',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const Divider(
                        height: 10,
                        color: GlobalColors.gray,
                        thickness: 1,
                        endIndent: 50,
                      ),
                      // SizedBox(height: 15.h),
                      IgnorePointer(
                        ignoring: isButtonTapped1,
                        child: TextButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              isButtonTapped1 = true;
                              searchClicked = false;
                              isSearching = false;
                              searchController.clear();
                              err = null;
                              allSearchedMer.clear();
                              selectedCategoryId = null;
                              selectedCategory = null;
                            });
                            LocationService()
                                .enableLocationAndFetchCountry()
                                .then((value) {
                              if (value == true) {
                                context.pushNamed('choose-on-map',
                                    pathParameters: {
                                      'appBarName': 'Choose On Map'
                                    }).then((value) {
                                  setState(() {
                                    isButtonTapped1 = false;
                                  });
                                  if (AppVariables.locationEnabledStatus.value >
                                          1 &&
                                      value == true) {
                                    AppVariables.locationEnabledStatus.value +=
                                        1;
                                  }
                                });
                              } else if (value == false) {
                                setState(() {
                                  isButtonTapped1 = false;
                                });
                              }
                            });
                          },
                          child: isButtonTapped1 == true
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GlobalColors.loaderColor,
                                )
                              : Row(
                                  children: [
                                    const Icon(
                                      Icons.map,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Text(
                                      S.of(context).chooseOnMap,
                                      //        'Choose on Map',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const Divider(
                        height: 10,
                        color: GlobalColors.gray,
                        thickness: 1,
                        endIndent: 50,
                      ),
                      const SizedBox(height: 15),
                      AutoSizeText(
                        allSearchedMer.isEmpty ? '' : S.of(context).merchant,
                        style: viewAllStyle,
                      ),
                      const SizedBox(height: 10),
                      isSearchedChanged == true
                          ? SizedBox(
                              height: 90.h,
                              child: const Center(child: CustomAllLoader1()),
                            )
                          : Column(
                              children: [
                                searchClicked == true
                                    ? searchedDataListedMer()
                                    : const SizedBox(),
                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            ),
                    ]),
              ),
            )));
  }

  //AppBar Serach Section
  appBarSearch() {
    return Form(
      key: searchKey,
      child: Container(
        height: 35.h,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
            colors: [GlobalColors.appColor, GlobalColors.appColor1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            controller: searchController,
            autofocus: true,
            cursorColor: GlobalColors.appColor,
            decoration: InputDecoration(
              fillColor: GlobalColors.paleGray,
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(15.0, 0.0, 11.0, 0.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.r),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              hintText: S.of(context).searchByLocation,
              // "Search by location",
              hintStyle: searchStyle,
            ),
            onTap: () {
              setState(() {
                isSearching = true;
              });
            },
          ),
        ),
      ),
    );
  }

  //Merchant List Data
  searchedDataListedMer() {
    return allSearchedMer.isEmpty
        ? const NoMerchantCard()
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10);
            },
            itemCount: allSearchedMer.length,
            itemBuilder: (context, index) {
              return InkWell(
                borderRadius: BorderRadius.circular(5.0),
                onTap: () {
                  context.pushNamed('details-screen', extra: {
                    'merchantID': allSearchedMer[index].xId.toString(),
                    'returnToSearch': true,
                    // 'isFavorite':
                    //     searchResultMer[index].favoriteMerchant != null
                    //         ? true
                    //         : false,
                  }).then((value) {
                    if (value == true) {
                      if (recallMerchantApi == false) {
                        recallMerchantApi = true;
                      }
                      loadSearchedList(
                          searchController.text.trim(), selectedCategoryId!);
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: const BoxConstraints(
                    maxHeight: double.infinity,
                  ),
                  child: ListTile(
                    tileColor: GlobalColors.appWhiteBackgroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      // Text Name
                      child: AutoSizeText(
                        allSearchedMer[index].xMerchantName!,
                        style: profileListStyle,
                      ),
                    ),

                    // Arrow
                    trailing: const Padding(
                      padding: EdgeInsets.only(top: 3.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 21,
                        color: GlobalColors.appColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
