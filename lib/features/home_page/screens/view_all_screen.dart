// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/not_available.dart';
import 'package:touristsaver/common/widgets/small_tab_container.dart';
import 'package:touristsaver/constants/app_image_string.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/features/home_page/services/home_dio.dart';

import '../../../common/app_variables.dart';
import '../../../models/request/nearby_req.dart';
import '../../../models/response/nearby_res.dart';
import 'package:touristsaver/generated/l10n.dart';

class ViewAllScreen extends StatefulWidget {
  static const String routeName = '/home-view-all';
  final String appBarName;
  const ViewAllScreen({super.key, required this.appBarName});

  @override
  State<ViewAllScreen> createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  // For Pagination
  int viewAllPage = 1;
  bool isFirstLoadingViewAll = false;
  // bool hasNextPageViewAll = true;
  // bool isLoadingMoreViewAll = false;
  // late ScrollController controllerViewAll;
  List<Datum> merViewAll = [];
  bool recallMerchantApi = false;

  //For Error First Load
  String? err;

  //First Load
  void firstLoadViewAll() async {
    if (!mounted) return;
    setState(() {
      isFirstLoadingViewAll = true;
    });
    try {
      if (widget.appBarName == 'Best Offers') {
        final resViewAll = await DioHome().getBestOffers(
          nearByLocationReqModel: NearByLocationReqModel(
            latitude: AppVariables.latitude,
            longitude: AppVariables.longitude,
            countryCode: AppVariables.countryCode,
            page: viewAllPage,
          ),
          limit: 30,
        );
        setState(() {
          merViewAll = resViewAll!.data!;
          merViewAll.sort((a, b) {
            return b.maxDiscount!.compareTo(a.maxDiscount!);
          });
        });
      } else {
        final resViewAll = await DioHome().getPopularOffers(
          nearByLocationReqModel: NearByLocationReqModel(
            latitude: AppVariables.latitude,
            longitude: AppVariables.longitude,
            countryCode: AppVariables.countryCode,
            page: viewAllPage,
          ),
          limit: 30,
        );
        setState(() {
          merViewAll = resViewAll!.data!;
          if (merViewAll.any((e) => e.popularOrder == null)) {
            List<Datum> merchantsWithPopularOrder =
                merViewAll.where((e) => e.popularOrder != null).toList();
            List<Datum> merchantsWithNullPopularOrder =
                merViewAll.where((e) => e.popularOrder == null).toList();
            merchantsWithPopularOrder.sort((a, b) {
              return a.popularOrder?.compareTo(b.popularOrder);
            });
            merViewAll.clear();
            merViewAll.addAll(merchantsWithPopularOrder);
            merViewAll.addAll(merchantsWithNullPopularOrder);
          } else {
            merViewAll.sort((a, b) {
              return a.popularOrder?.compareTo(b.popularOrder);
            });
          }
        });
      }
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

  //Load More
  // void loadMoreViewAll() async {
  //   if (hasNextPageViewAll == true &&
  //       isFirstLoadingViewAll == false &&
  //       isLoadingMoreViewAll == false &&
  //       controllerViewAll.position.extentAfter < 300) {
  //     if (!mounted) return;
  //     setState(() {
  //       isLoadingMoreViewAll = true;
  //     });
  //     viewAllPage += 1;

  //     try {
  //       if (widget.appBarName == bestMerText) {
  //         final res = await DioHome().getBestOffers(
  //           nearByLocationReqModel: NearByLocationReqModel(
  //             latitude: AppVariables.latitude,
  //             longitude: AppVariables.longitude,
  //             page: viewAllPage,
  //           ),
  //         );
  //         final List<Datum> fetchMerViewAll = res!.data!;
  //         if (fetchMerViewAll.isNotEmpty) {
  //           setState(() {
  //             merViewAll.addAll(fetchMerViewAll);
  //           });
  //         } else {
  //           setState(() {
  //             hasNextPageViewAll = false;
  //           });
  //         }
  //         // final res = await DioHome().getBestMerchant(pageNumber: viewAllPage);
  //         // final List<Datum> fetchMerViewAll = res!.data!;

  //         // if (fetchMerViewAll.isNotEmpty) {
  //         //   if (!mounted) return;
  //         //   setState(() {
  //         //     merViewAll.addAll(fetchMerViewAll);
  //         //   });
  //         // } else {
  //         //   if (!mounted) return;
  //         //   setState(() {
  //         //     hasNextPageViewAll = false;
  //         //   });
  //         // }
  //       } else {
  //         final res = await DioHome().getPopularOffers(
  //           nearByLocationReqModel: NearByLocationReqModel(
  //             latitude: AppVariables.latitude,
  //             longitude: AppVariables.longitude,
  //             page: viewAllPage,
  //           ),
  //         );
  //         final List<Datum> fetchMerViewAll = res!.data!;
  //         if (fetchMerViewAll.isNotEmpty) {
  //           setState(() {
  //             merViewAll.addAll(fetchMerViewAll);
  //           });
  //         } else {
  //           setState(() {
  //             hasNextPageViewAll = false;
  //           });
  //         }
  //         // final res =
  //         //     await DioHome().getPopularMerchant(pageNumber: viewAllPage);
  //         // final List<Datum> fetchMerViewAll = res!.data!;

  //         // if (fetchMerViewAll.isNotEmpty) {
  //         //   if (!mounted) return;
  //         //   setState(() {
  //         //     merViewAll.addAll(fetchMerViewAll);
  //         //   });
  //         // } else {
  //         //   if (!mounted) return;
  //         //   setState(() {
  //         //     hasNextPageViewAll = false;
  //         //   });
  //         // }
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print('Something went wrong!');
  //       }
  //     }
  //     if (!mounted) return;
  //     setState(() {
  //       isLoadingMoreViewAll = false;
  //     });
  //   }
  // }

  reloadOk() async {
    firstLoadViewAll();
    // controllerViewAll = ScrollController()..addListener(loadMoreViewAll);
    err = null;
  }

  @override
  void initState() {
    super.initState();
    firstLoadViewAll();
    // controllerViewAll = ScrollController()..addListener(loadMoreViewAll);
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
                text: widget.appBarName == 'Best Offers'
                    ? S.of(context).bestOffers
                    : S.of(context).popularMerchants,
                icon: Icons.arrow_back_ios,
                onPressed: () {
                  context.pop(recallMerchantApi);
                }),
          ),
          body: isFirstLoadingViewAll
              ? const CustomLoader()
              : err == 'Something went wrong'
                  ? const Error1()
                  : merViewAll.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: NotAvailable(
                              image: "assets/images/no-merchant.png",
                              titleText: S.of(context).noMerchantAvailable,
                              bodyText: S
                                  .of(context)
                                  .noMerchantIsAvailableRightNowWeWillKeepYouUpdated),
                        )
                      : viewAllSelectedMerchant()),
    );
  }

  // Viewing all the selected merchant
  viewAllSelectedMerchant() {
    return RefreshIndicator(
      onRefresh: () {
        setState(() {
          viewAllPage = 1;
        });
        return reloadOk();
      },
      color: GlobalColors.appColor,
      child: SingleChildScrollView(
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
              // controller: controllerViewAll,
              itemBuilder: ((context, index) {
                return SmallTabContainer(
                  smallOnTap: () {
                    context.pushNamed('details-screen', extra: {
                      'merchantID': merViewAll[index].id.toString(),
                      // 'isFavorite': merViewAll[index].favoriteMerchant != null
                      //     ? true
                      //     : false,
                    }).then((value) {
                      if (value == true) {
                        if (recallMerchantApi == false) {
                          recallMerchantApi = true;
                        }
                        firstLoadViewAll();
                      }
                    });
                  },
                  smallImage: merViewAll[index].merchantImageInfoLogoUrl ??
                      merViewAll[index].merchantImageInfoSlider1 ??
                      AppImageString.appNoImageURL,
                  smallMerchantName:
                      merViewAll[index].merchantName ?? '.......',
                  smallDiscountGiven: merViewAll[index].maxDiscount.toString(),
                  distance: merViewAll[index].distance,
                );
              }),
            ),
            // checking and loading more
            // if (isLoadingMoreViewAll == true)
            //   const Padding(
            //     padding: EdgeInsets.symmetric(vertical: 10.0),
            //     child: CircularProgressIndicator(
            //       color: GlobalColors.appColor,
            //       strokeWidth: 2.0,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
