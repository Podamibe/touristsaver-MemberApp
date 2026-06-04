import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/dropdown_button_widget.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/small_tab_container.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/features/home_page/services/home_dio.dart';

import '../../../common/app_variables.dart';
import '../../../constants/app_image_string.dart';
import '../../../constants/style.dart';
import '../../../models/response/get_nearby_merchants_res_model.dart'
    as near_mer;
import '../../../models/response/get_range_res.dart' as get_range;
import 'package:touristsaver/generated/l10n.dart';

class ViewAllNearbyMerchantsScreen extends StatefulWidget {
  static const String routeName = '/view-all-nearby-merchants';

  const ViewAllNearbyMerchantsScreen({super.key});

  @override
  State<ViewAllNearbyMerchantsScreen> createState() =>
      ViewAllNearbyMerchantsScreenState();
}

class ViewAllNearbyMerchantsScreenState
    extends State<ViewAllNearbyMerchantsScreen> {
  // For Pagination
  int viewAllPage = 1;
  bool hasNextPageViewAll = true;
  bool isLoadingMoreViewAll = false;
  late ScrollController controllerViewAll;
  bool isFirstLoadingViewAll = false;
  List<near_mer.Datum> merViewAll = [];
  List<get_range.Datum> resRangeNearBy = [];
  bool recallMerchantApi = false;

  //For Error First Load
  String? err;
  TextEditingController searchController = TextEditingController();
  String selectedItem = '';

  Future<void> loadRange() async {
    get_range.GetNearByRangeResModel? getNearByRangeResModel =
        await DioHome().getNearByRange();
    if (!mounted) return;
    setState(() {
      resRangeNearBy = getNearByRangeResModel!.data!;
      selectedItem = getNearByRangeResModel.data!
          .map((e) => e.distanceRange)
          .first
          .toString();
    });
  }

  // First Load
  Future<void> firstLoadViewAll(String selectedItemm) async {
    if (!mounted) return;
    setState(() {
      isFirstLoadingViewAll = true;
    });
    try {
      near_mer.GetNearByMerchantsResModel? getNearByMerchantsResModel =
          await DioHome().getNearbyOffers(
        latitude: AppVariables.latitude,
        longitude: AppVariables.longitude,
        radius: double.parse(selectedItemm),
      );
      setState(() {
        merViewAll = getNearByMerchantsResModel!.data!;
        // merViewAll.sort((a, b) {
        //   return a.distance!.compareTo(b.distance!);
        // });
      });
    } catch (e) {
      if (kDebugMode) {
        err = 'Something went wrong';
      }
    }
    setState(() {
      if (!mounted) return;
      isFirstLoadingViewAll = false;
    });
  }

  //  Load More
  Future<void> loadMoreViewAll() async {
    if (hasNextPageViewAll == true &&
        isFirstLoadingViewAll == false &&
        isLoadingMoreViewAll == false &&
        controllerViewAll.position.extentAfter < 300) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreViewAll = true;
      });
      viewAllPage += 1;
      try {
        near_mer.GetNearByMerchantsResModel? getNearByMerchantsResModel =
            await DioHome().getNearbyOffers(
          latitude: AppVariables.latitude,
          longitude: AppVariables.longitude,
          radius: double.parse(selectedItem),
        );
        final List<near_mer.Datum> fetchMerViewAll =
            getNearByMerchantsResModel!.data!;
        if (fetchMerViewAll.isNotEmpty) {
          setState(() {
            merViewAll.addAll(fetchMerViewAll);
          });
        } else {
          setState(() {
            hasNextPageViewAll = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }
      if (!mounted) return;
      setState(() {
        isLoadingMoreViewAll = false;
      });
    }
  }

  reloadOk() async {
    //  firstLoadViewAll(selectedItem = selectedItem);
    controllerViewAll = ScrollController()..addListener(loadMoreViewAll);
    err = null;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadRange();
      await firstLoadViewAll(selectedItem);
    });
    controllerViewAll = ScrollController()..addListener(loadMoreViewAll);
  }

  @override
  Widget build(BuildContext context) {
    return
        //  WillPopScope(
        //     onWillPop: () async {
        //       context.pop(recallMerchantApi);
        //       return true;
        //     },
        //     child:
        Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      color: GlobalColors.appGreyBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(2, 2))
                      ]),
                ),
                elevation: 0.0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.black.withValues(alpha: 0.8),
                  onPressed: () {
                    context.pop(recallMerchantApi);
                  },
                  iconSize: 20,
                ),
                title: Text(
                  textAlign: TextAlign.left,
                  S.of(context).nearbyMerchants,
                  style: appbarTitleStyle,
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      right: 10.w,
                    ),
                    child: Container(
                      width: 130.w,
                      decoration: BoxDecoration(
                          border: Border.all(color: GlobalColors.textColor)),
                      child: DropdownButtonWidget(
                        label: S
                            .of(context)
                            .selectCategory
                            .replaceAll('Category', ''),
                        //'Select',
                        searchController: searchController,
                        dropWidth: 130.w,
                        lPadding: 15,
                        iHeight: 35,
                        items: resRangeNearBy.map((e) {
                          return DropdownMenuItem(
                            value: e.distanceRange.toString(),
                            child: Padding(
                              padding: EdgeInsets.only(left: 25.w),
                              child: AutoSizeText(
                                '${e.distanceRange.toString()} ${e.rangeUnitType.toString().toUpperCase()}',
                                style: dopdownTextStyle,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newVal) async {
                          setState(() {
                            selectedItem = newVal as String;
                            // log(selectedItem.toString());
                          });
                          firstLoadViewAll(selectedItem);
                        },
                        value: selectedItem,
                      ),
                    ),
                  ),
                  //  ),
                  // ),
                ],
                centerTitle: false,
              ),
            ),
            body: isFirstLoadingViewAll
                ? const CustomLoader()
                : err == 'Something went wrong'
                    ? const Error1()
                    // : merViewAll.isEmpty
                    //     ? Padding(
                    //         padding: const EdgeInsets.all(10.0),
                    //         child: NotAvailable(
                    //             image: "assets/images/no-merchant.png",
                    //             titleText: noMerAva,
                    //             bodyText:
                    //                 'No Merchant is available right now. We will keep you updated.'),
                    //       )
                    : viewAllSelectedMerchant());
    //);
  }

  // Viewing all the selected merchant
  viewAllSelectedMerchant() {
    return
        //  RefreshIndicator(
        //     onRefresh: () {
        //       return reloadOk();
        //     },
        //     color: GlobalColors.appColor,
        //     child:
        SingleChildScrollView(
      // controller: controllerViewAll,
      child: Column(
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25),
            itemCount: merViewAll.length,
            controller: controllerViewAll,
            itemBuilder: ((context, index) {
              return SmallTabContainer(
                smallOnTap: () {
                  context.pushNamed('details-screen', extra: {
                    'merchantID': merViewAll[index].id.toString(),
                    // 'isFavorite': merViewAll[index].favoritemerchant != null
                    //     ? true
                    //     : false,
                  }).then((value) {
                    if (value == true) {
                      if (recallMerchantApi == false) {
                        recallMerchantApi = true;
                      }
                      firstLoadViewAll(selectedItem);
                    }
                  });
                },
                smallImage: merViewAll[index].merchantImageInfoLogoUrl ??
                    merViewAll[index].merchantImageInfoSlider1 ??
                    AppImageString.appNoImageURL,
                smallMerchantName: merViewAll[index].merchantname ?? '.....',
                smallDiscountGiven: merViewAll[index].maxdiscount.toString(),
                distance: merViewAll[index].distance,
              );
            }),
          ),
          // checking and loading more
          if (isLoadingMoreViewAll == true)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: CircularProgressIndicator(
                color: GlobalColors.loaderColor,
                strokeWidth: 2.0,
              ),
            ),
        ],
      ),
      //   )
    );
  }
}
