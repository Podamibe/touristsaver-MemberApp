// ignore_for_file: deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/common/widgets/not_available.dart';
import 'package:new_piiink/common/widgets/small_tab_container.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/home_page/services/home_dio.dart';
import 'package:new_piiink/models/response/merchant_get_all_res.dart'
    as merchantlist;
import 'package:new_piiink/models/response/sub_category_list_res.dart' as sub;

import '../../../common/widgets/custom_snackbar.dart';
import '../../../constants/app_image_string.dart';
import '../../../models/request/mark_fav_req.dart';
import '../../../models/response/common_res.dart';
import '../../merchant/services/dio_merchant.dart';
import 'package:new_piiink/generated/l10n.dart';

class CategoryScreen extends StatefulWidget {
  // final String categoryName;
  final String parentId;
  static const String routeName = '/category-screen';
  const CategoryScreen(
      {super.key,
      // required this.categoryName,
      required this.parentId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Choosing the sub category
  String? selectedSubCategory;
  int? selectedId;
  bool recallMerchantApi = false;
  bool isLoading = false;

  // Getting sub catgeory
  Future<sub.SubCategoryListResModel?>? subCategory;
  Future<sub.SubCategoryListResModel?>? getSubCategory(String parentId) async {
    sub.SubCategoryListResModel? subCategoryList =
        await DioHome().getSubCategory(int.parse(parentId));
    // // Using this method to filter the data that are to be visible in app or not
    // subCategoryList!.data!.isEmpty
    //     ? null
    // : List.generate(subCategoryList.data!.length, (index) {
    //     subCategoryList.data![index].isVisibleOnApp == true
    //         ? newSubCategory.add(subCategoryList.data![index])
    //         : null;
    //   });
    return subCategoryList;
  }

  // // For Pagination Start using Infinite Scroll Pagination
  // final PagingController<int, merchantList.Datum> _pagingController =
  //     PagingController(
  //   firstPageKey: 1,
  // );
  // bool noMoreItems = false;
  // // For Pagination Start using Infinite Scroll Pagination

  // Next pagination style
  int page = 1;
  bool isFirstLoading = false;
  bool hasNextPage = true;
  bool isLoadingMore = false;
  late ScrollController controller;
  List<merchantlist.Datum> mer = [];

  //For Error First Load
  String? err;

  // First Load
  void firstLoad() async {
    if (!mounted) return;
    setState(() {
      isFirstLoading = true;
    });

    try {
      final res = await DioHome()
          .getAllMerchant(pageNumber: page, categoryId: selectedId!);
      if (!mounted) return;
      setState(() {
        mer = res!.data!;
      });
    } catch (e) {
      if (kDebugMode) {
        err = 'Something went wrong';
      }
    }
    if (!mounted) return;
    setState(() {
      isFirstLoading = false;
    });
  }

// Load More
  void loadMore() async {
    if (hasNextPage == true &&
        isFirstLoading == false &&
        isLoadingMore == false &&
        controller.position.extentAfter < 300) {
      if (!mounted) return;
      setState(() {
        isLoadingMore = true;
      });
      page += 1;

      try {
        final res = await DioHome()
            .getAllMerchant(pageNumber: page, categoryId: selectedId!);

        final List<merchantlist.Datum> fetchMer = res!.data!;

        if (fetchMer.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            mer.addAll(fetchMer);
          });
        } else {
          if (!mounted) return;
          setState(() {
            hasNextPage = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print(S.of(context).somethingWentWrong);
        }
      }
      if (!mounted) return;
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  // For the refresh Indicator
  final GlobalKey<RefreshIndicatorState> refreshIndicatorProfile =
      GlobalKey<RefreshIndicatorState>();
  reloadOk() async {
    firstLoad();
    controller = ScrollController()..addListener(loadMore);
    err = null;
  }

  // Adding to Favourite Merchant
  favResClicked(merchantlist.Datum merchant) async {
    setState(() {
      isLoading = true;
    });
    var favRes = await DioMerchant().markFavouriteMerchants(
        markFavouriteReqModel: MarkFavouriteReqModel(merchantId: merchant.id));
    if (!mounted) return;
    if (favRes is CommonResModel) {
      if (favRes.status == "Success") {
        recallMerchantApi = true;
        setState(() {
          mer
              .firstWhere((e) => e.id == merchant.id,
                  orElse: () => merchantlist.Datum())
              .favoriteMerchant = merchantlist.FavoriteMerchant();
        });
        GlobalSnackBar.showSuccess(
            context, S.of(context).merchantAddedToFavorites);
      } else {
        GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
      }
    } else {
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
    }
    setState(() {
      isLoading = false;
    });
  }

  // Removing from Favourite Merchant
  removeFavRes(int? merchantId) async {
    setState(() {
      isLoading = true;
    });
    var removeRes =
        await DioMerchant().removeFavouriteMerchants(merchantID: merchantId!);
    if (!mounted) return;
    if (removeRes is SecondCommonResModel) {
      if (removeRes.status == "Success") {
        recallMerchantApi = true;
        setState(() {
          mer
              .firstWhere((e) => e.id == merchantId,
                  orElse: () => merchantlist.Datum())
              .favoriteMerchant = null;
        });
        GlobalSnackBar.showSuccess(
            context, S.of(context).merchantRemovedFromFavorites);
      } else {
        GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
      }
    } else {
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    subCategory = getSubCategory(widget.parentId);
    selectedId = int.parse(widget.parentId);
    firstLoad();
    controller = ScrollController()..addListener(loadMore);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<sub.SubCategoryListResModel?>(
        future: subCategory,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: CustomAppBar(
                    text: S.of(context).error,
                    icon: Icons.arrow_back_ios,
                    onPressed: () {
                      context.pop();
                    },
                  )),
              body: const Error1(),
            );
          } else if (!snapshot.hasData) {
            return Scaffold(
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: CustomAppBar(
                    text: '...',
                    icon: Icons.arrow_back_ios,
                    onPressed: () {
                      context.pop();
                    },
                  )),
              body: const CustomLoader(),
            );
          } else {
            return WillPopScope(
              onWillPop: () async {
                context.pop(recallMerchantApi);
                return true;
              },
              child: Scaffold(
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
                      iconSize: 20,
                      onPressed: () {
                        context.pop(recallMerchantApi);
                      },
                    ),
                    centerTitle: true,
                    title: snapshot.data!.data!.isEmpty
                        ? Tooltip(
                            message: selectedSubCategory,
                            //  widget.categoryName,
                            child: AutoSizeText(
                              selectedSubCategory.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: dopdownTextStyle,
                            ),
                          )
                        : SizedBox(
                            width: 250,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                iconStyleData: IconStyleData(
                                  icon: const Icon(
                                    Icons.expand_more,
                                    size: 20,
                                    color: GlobalColors.appColor,
                                  ),
                                  openMenuIcon: const Icon(
                                    Icons.expand_less,
                                    size: 20,
                                    color: GlobalColors.appColor,
                                  ),
                                ),
                                items: snapshot.data!.data!.map((e) {
                                  if (selectedId.toString() ==
                                      e.id.toString()) {
                                    selectedSubCategory = e.name;
                                  }
                                  return DropdownMenuItem(
                                    value: e.name,
                                    child: Tooltip(
                                      message: e.name,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        child: AutoSizeText(
                                          e.name!,
                                          overflow: TextOverflow.ellipsis,
                                          style: dopdownTextStyle,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedSubCategory = newValue;
                                  });
                                  final catId = snapshot.data!.data!.firstWhere(
                                      (element) =>
                                          element.name == selectedSubCategory);
                                  selectedId = catId.id;
                                  page = 1;
                                  err = null;
                                  firstLoad();
                                  controller = ScrollController()
                                    ..addListener(loadMore);
                                },
                                value: selectedSubCategory,
                                buttonStyleData: const ButtonStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 50,
                                  width: 250,
                                ),
                                dropdownStyleData: const DropdownStyleData(
                                  maxHeight: 250,
                                  width: 250,
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                ),
                                isExpanded: true,
                              ),
                            ),
                          ),
                  ),
                ),
                body: Stack(
                  alignment: Alignment.center,
                  children: [
                    SingleChildScrollView(
                        controller: controller,
                        child: isFirstLoading
                            ? const CustomLoader()
                            : err == 'Something went wrong'
                                ? const Error1()
                                : mer.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: NotAvailable(
                                            titleText: S
                                                .of(context)
                                                .noMerchantAvailable,
                                            image:
                                                "assets/images/no-merchant.png",
                                            bodyText: S
                                                .of(context)
                                                .noMerchantIsAvailableRightNowWeWillKeepYouUpdated),
                                      )
                                    : categoryMerchantList()),
                    if (isLoading)
                      Positioned(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: GlobalColors.gray.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const CustomAllLoader1(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        });
  }

  // Category Merchant List
  categoryMerchantList() {
    return RefreshIndicator(
      key: refreshIndicatorProfile,
      onRefresh: () {
        setState(() {
          page = 1;
        });
        return reloadOk();
      },
      color: GlobalColors.appColor,
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
            itemCount: mer.length,
            itemBuilder: ((context, index) {
              return NewSmallTabContainerWithFav(
                newSmallOnTap: () {
                  context.pushNamed('details-screen', extra: {
                    'merchantID': mer[index].id.toString(),
                    // 'isFavorite':
                    //     mer[index].favoriteMerchant != null ? true : false,
                  }).then((value) {
                    if (value == true) {
                      if (recallMerchantApi == false) {
                        recallMerchantApi = true;
                      }
                      page = 1;
                      err = null;
                      firstLoad();
                      controller = ScrollController()..addListener(loadMore);
                    }
                  });
                },
                newSmallImage: mer[index].merchantImageInfo == null
                    ? AppImageString.appNoImageURL
                    : mer[index].merchantImageInfo?.logoUrl ??
                        mer[index].merchantImageInfo?.slider1 ??
                        AppImageString.appNoImageURL,
                newSmallMerchantName: mer[index].merchantName!,
                newSmallDiscountGiven: mer[index].maxDiscount.toString(),
                newFavouriteTap: () async {
                  mer[index].favoriteMerchant == null
                      ? favResClicked(mer[index])
                      : removeFavRes(mer[index].id!);
                },
                newIsFavouriteTap:
                    mer[index].favoriteMerchant == null ? false : true,
              );
            }),
          ),

          // checking and loading more
          if (isLoadingMore == true)
            const CircularProgressIndicator(
              color: GlobalColors.loaderColor,
              strokeWidth: 2.0,
            ),
        ],
      ),
    );
  }
}
