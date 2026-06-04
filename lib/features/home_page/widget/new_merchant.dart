import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/services/dio_common.dart';
import 'package:touristsaver/constants/app_image_string.dart';
import 'package:touristsaver/features/home_page/widget/big_tab_container.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/no_merchant.dart';
import 'package:touristsaver/common/widgets/reg_log_slider.dart';
import 'package:touristsaver/common/widgets/small_tab_container.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/home_page/services/home_dio.dart';
import 'package:touristsaver/features/merchant/bloc/merchant_bloc.dart';
import 'package:touristsaver/features/merchant/services/dio_merchant.dart';
import 'package:touristsaver/models/request/mark_fav_req.dart';
import 'package:touristsaver/models/response/common_res.dart';
import 'package:touristsaver/models/response/merchant_get_all_res.dart';
import 'package:touristsaver/models/response/piiink_info_res.dart';

import '../../../common/app_variables.dart';
import '../../../common/widgets/error.dart';
import 'package:touristsaver/generated/l10n.dart';

class NewMerchant extends StatefulWidget {
  const NewMerchant({super.key});

  @override
  State<NewMerchant> createState() => _NewMerchantState();
}

class _NewMerchantState extends State<NewMerchant> {
  List<Datum>? allMerchants;
  bool allMerchantsLoading = true;
  List<Datum>? favoriteMerchants;
  bool favoriteMerchantsLoading = true;
  // bool mapViewSelected = false;

  // Getting all merchants
  Future<MerchantGetAllResModel?>? newMerchantAPI;
  Future<void> getAllMerchants() async {
    try {
      MerchantGetAllResModel? merchantGetAllResModel =
          await DioHome().getNewMerchant(pageNumber: 1);
      setState(() {
        allMerchants = merchantGetAllResModel?.data ?? [];
        allMerchantsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        allMerchantsLoading = false;
      });
    }
  }

  void onTapped(Datum merchant, bool isFavorite) {
    context.pushNamed('details-screen', extra: {
      'merchantID': merchant.id.toString(),
      //  'isFavorite': isFavorite,
    }).then((value) async {
      if (value == true) {
        recallMerchantApi();
      }
    });
  }

  // Recommend Merchant Link
  Future<PiiinkInfoResModel?>? showRecommend;
  Future<PiiinkInfoResModel?> getShowRecommend() async {
    PiiinkInfoResModel? piiinkInfoResModel = await DioCommon().piiinkInfo();
    return piiinkInfoResModel;
  }

  // Getting all favorite merchants
  Future<MerchantGetAllResModel?>? favouriteSection;
  Future<void> getFavouriteSection() async {
    try {
      MerchantGetAllResModel? getAllFavouriteMerchantResModel =
          await DioMerchant().getAllFavouriteMerchants();
      setState(() {
        favoriteMerchants = getAllFavouriteMerchantResModel?.data ?? [];
        favoriteMerchantsLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          favoriteMerchantsLoading = false;
        });
      }
    }
  }

  recallMerchantApi() async {
    setState(() {
      favoriteMerchantsLoading = true;
      allMerchantsLoading = true;
    });
    getFavouriteSection();
    getAllMerchants();
  }

  @override
  void initState() {
    if (AppVariables.accessToken != null) {
      showRecommend = getShowRecommend();
      getFavouriteSection();
    }
    getAllMerchants();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Favourite Merchant
        if (AppVariables.accessToken != null)
          favoriteMerchantsLoading
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: AutoSizeText(
                        S.of(context).favouriteMerchants,
                        style: topicStyle,
                      ),
                    ),
                    const CustomLoader1(),
                  ],
                )
              : favoriteMerchants == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: AutoSizeText(
                            S.of(context).favouriteMerchants,
                            style: topicStyle,
                          ),
                        ),
                        ErrorData(
                            text: S.of(context).couldnTFetchTheFavouriteData),
                      ],
                    )
                  : favoriteMerchants!.isEmpty
                      ? const SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: AutoSizeText(
                                S.of(context).favouriteMerchants,
                                style: topicStyle,
                              ),
                            ),
                            const SizedBox(height: 15),
                            favouriteMerchants(favoriteMerchants!),
                          ],
                        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: AutoSizeText(
                      S.of(context).merchants,
                      style: topicStyle,
                      maxLines: 1,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (AppVariables.accessToken != null)
                            showingRecommendMerchant(),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              context.pushNamed('all-merchant').then((value) {
                                if (value == true) {
                                  recallMerchantApi();
                                }
                              });
                            },
                            child: SizedBox(
                              child: Row(
                                children: [
                                  AutoSizeText(
                                    S.of(context).viewAll,
                                    style: viewAllStyle,
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: GlobalColors.appColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.w),
              SizedBox(
                height: 30.h,
                width: 100.w,
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed('map-view-merchant').then((value) {
                      if (value == true) {
                        recallMerchantApi();
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: GlobalColors.appColor1,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FittedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3.w),
                          Text(S.of(context).mapView,
                              //'Map View',
                              style:
                                  viewAllStyle.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        allMerchantsLoading
            ? const CustomLoader()
            : allMerchants == null
                ? const Error()
                : allMerchants!.isEmpty
                    ? const NoMerchantCard()
                    : newMerchantGrid(allMerchants!),
      ],
    );
  }

  // Favourite Merchants ListView
  favouriteMerchants(List<Datum> favoriteMerchants) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        separatorBuilder: (context, index) {
          return const SizedBox(width: 25);
        },
        itemCount: favoriteMerchants.length,
        itemBuilder: (context, index) {
          return NewBigTabContainerWithFav(
            newbigDiscountGiven:
                favoriteMerchants[index].maxDiscount.toString(),
            newbigMerchantName: favoriteMerchants[index].merchantName!,
            newbigImage: favoriteMerchants[index].merchantImageInfo == null
                ? AppImageString.appNoImageURL
                : favoriteMerchants[index].merchantImageInfo?.slider1 ??
                    AppImageString.appNoImageURL,
            newbigLogo: favoriteMerchants[index].merchantImageInfo == null
                ? AppImageString.appNoImageURL
                : favoriteMerchants[index].merchantImageInfo?.logoUrl ??
                    AppImageString.appNoImageURL,
            newbigOnTap: () {
              onTapped(favoriteMerchants[index], true);
            },
            newbigFavouriteTap: () {
              removeFromFavorite(favoriteMerchants[index]);
            },
            newbigIsFavouriteTap:
                favoriteMerchants[index].favoriteMerchant == null
                    ? false
                    : true,
          );
        },
      ),
    );
  }

  //showing recommend merchant link or not
  showingRecommendMerchant() {
    return FutureBuilder<PiiinkInfoResModel?>(
        future: showRecommend,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox();
          } else if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return snapshot.data?.data?.hideReferredMerchantInApp == false
                ? InkWell(
                    onTap: () {
                      context.pushNamed('recommend');
                    },
                    child: SizedBox(
                      child: Row(
                        children: [
                          AutoSizeText(
                            S.of(context).recommendNewMerchant,
                            style: viewAllStyle,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: GlobalColors.appColor,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox();
          }
        });
  }

  // New Merchant Grid
  newMerchantGrid(List<Datum> allMerchants) {
    return allMerchants.isEmpty
        ? const NoMerchantCard()
        : GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25),
            itemCount: allMerchants.length,
            itemBuilder: ((context, index) {
              return NewSmallTabContainerWithFav(
                newSmallOnTap: () {
                  onTapped(
                      allMerchants[index],
                      allMerchants[index].favoriteMerchant != null
                          ? true
                          : false);
                },
                newSmallImage: allMerchants[index].merchantImageInfo == null
                    ? AppImageString.appNoImageURL
                    : allMerchants[index].merchantImageInfo?.logoUrl ??
                        allMerchants[index].merchantImageInfo?.slider1 ??
                        AppImageString.appNoImageURL,
                newSmallMerchantName: allMerchants[index].merchantName!,
                newSmallDiscountGiven:
                    allMerchants[index].maxDiscount.toString(),
                newFavouriteTap: () async {
                  allMerchants[index].favoriteMerchant == null
                      ? addToFavorite(allMerchants[index])
                      : removeFromFavorite(allMerchants[index]);
                },
                newIsFavouriteTap:
                    allMerchants[index].favoriteMerchant == null ? false : true,
              );
            }),
          );
  }

  // Adding to Favourite Merchant
  addToFavorite(Datum merchant) async {
    BlocProvider.of<MerchantBloc>(context).add(const FavoriteLoadingEvent());
    var favRes = await DioMerchant().markFavouriteMerchants(
        markFavouriteReqModel: MarkFavouriteReqModel(merchantId: merchant.id));
    if (!mounted) return;
    if (favRes is CommonResModel) {
      if (favRes.status == "Success") {
        setState(() {
          favoriteMerchants
              ?.add(merchant.copyWith(favoriteMerchant: FavoriteMerchant()));
          allMerchants
              ?.firstWhere((e) => e.id == merchant.id)
              .favoriteMerchant = FavoriteMerchant();
        });
        GlobalSnackBar.showSuccess(
            context, S.of(context).merchantAddedToFavorites);
      } else {
        GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
      }
    } else {
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
    }
    BlocProvider.of<MerchantBloc>(context).add(const FavoriteLoadedEvent());
  }

  // Removing from Favourite Merchant
  removeFromFavorite(Datum merchant) async {
    BlocProvider.of<MerchantBloc>(context).add(const FavoriteLoadingEvent());
    var removeRes =
        await DioMerchant().removeFavouriteMerchants(merchantID: merchant.id!);
    if (!mounted) return;
    if (removeRes is SecondCommonResModel) {
      if (removeRes.status == "Success") {
        setState(() {
          favoriteMerchants?.removeWhere((e) => e.id == merchant.id);
          if (allMerchants != null && allMerchants!.isNotEmpty) {
            allMerchants
                ?.firstWhere((e) => e.id == merchant.id, orElse: () => Datum())
                .favoriteMerchant = null;
          }
        });
        GlobalSnackBar.showSuccess(
            context, S.of(context).merchantRemovedFromFavorites);
      } else {
        GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
      }
    } else {
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
    }
    BlocProvider.of<MerchantBloc>(context).add(const FavoriteLoadedEvent());
  }

  // NOt Login / Not Used For Now
  recommendMerchantSlider() {
    return showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width /
              1.1, // here increase or decrease in width
        ),
        builder: (context) {
          return RegLogSlider(
              title: S.of(context).recommendNewMerchant,
              body: S
                  .of(context)
                  .forRecommendingTheNewMerchantRegisterMembershipOrLogIn,
              onregister: () {
                context.pop();
                context.pushNamed('register', queryParameters: {
                  'issuercode': '',
                  'memberReferralCode': ''
                });
              },
              onLogin: () {
                context.pop();
                context.pushNamed('login');
              },
              image: 'assets/images/member-card.png');
        });
  }
}
