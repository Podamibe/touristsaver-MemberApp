import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/constants/app_image_string.dart';
import 'package:new_piiink/features/home_page/widget/big_tab_container.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/home_page/services/home_dio.dart';
import 'package:new_piiink/features/home_page/widget/home_section_header.dart';

import '../../../common/widgets/no_merchant.dart';
import '../../../constants/location_not_enable.dart';
import '../../../models/request/nearby_req.dart';
import '../../../models/response/nearby_res.dart';
import 'package:new_piiink/generated/l10n.dart';

class PopularMerchant extends StatefulWidget {
  const PopularMerchant({super.key, required this.isLoading});

  final bool isLoading;

  @override
  PopularMerchantState createState() => PopularMerchantState();
}

class PopularMerchantState extends State<PopularMerchant> {
  bool isLoading = false;

  // Calling API of NearByLocation
  Future<NearByLocationResModel>? popularOfferRes;
  Future<NearByLocationResModel>? getPopularOfferRes() async {
    NearByLocationResModel nearByLocationResModel =
        await DioHome().getPopularOffers(
      nearByLocationReqModel: NearByLocationReqModel(
        latitude: AppVariables.latitude,
        longitude: AppVariables.longitude,
        countryCode: AppVariables.countryCode,
        page: 1,
      ),
    );
    return nearByLocationResModel;
  }

  @override
  void initState() {
    isLoading = widget.isLoading;
    if (AppVariables.locationEnabledStatus.value > 1) {
      popularOfferRes = getPopularOfferRes();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: AutoSizeText(
                  S.of(context).popularMerchants,
                  style: topicStyle,
                ),
              ),
              const SizedBox(height: 15),
              const CustomLoader(itemCount: 2),
            ],
          )
        : AppVariables.locationEnabledStatus.value > 1
            ? locationEnabled()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AutoSizeText(
                      S.of(context).popularMerchants,
                      style: topicStyle,
                    ),
                  ),
                  const SizedBox(height: 15),
                  LocationNotEnabled(
                      text: S
                          .of(context)
                          .weWantToSetYourActualLocationToShowYouThePopularMerchantsNearby),
                ],
              );
  }

  // When location is enabled
  locationEnabled() {
    return FutureBuilder<NearByLocationResModel?>(
        future: popularOfferRes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: AutoSizeText(
                    S.of(context).popularMerchants,
                    style: topicStyle,
                  ),
                ),
                const SizedBox(height: 15),
                const Error(),
              ],
            );
          } else if (!snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: AutoSizeText(
                    S.of(context).popularMerchants,
                    style: topicStyle,
                  ),
                ),
                const SizedBox(height: 15),
                const CustomLoader(itemCount: 2),
              ],
            );
          } else {
            List<Datum> nearbyMerchants = snapshot.data!.data!;
            if (nearbyMerchants.any((e) => e.popularOrder == null)) {
              List<Datum> merchantsWithPopularOrder =
                  nearbyMerchants.where((e) => e.popularOrder != null).toList();
              List<Datum> merchantsWithNullPopularOrder =
                  nearbyMerchants.where((e) => e.popularOrder == null).toList();
              merchantsWithPopularOrder.sort((a, b) {
                return a.popularOrder?.compareTo(b.popularOrder);
              });
              nearbyMerchants.clear();
              nearbyMerchants.addAll(merchantsWithPopularOrder);
              nearbyMerchants.addAll(merchantsWithNullPopularOrder);
            } else {
              nearbyMerchants.sort((a, b) {
                return a.popularOrder?.compareTo(b.popularOrder);
              });
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeSectionHeader(
                  title: S.of(context).popularMerchants,
                  viewAllLabel: S.of(context).viewAll,
                  onViewAllTap: nearbyMerchants.isEmpty
                      ? null
                      : () {
                          context.pushNamed('home-view-all', pathParameters: {
                            'appBarName': 'Popular Merchants'
                          }).then((value) {
                            if (value == true) {
                              AppVariables.locationEnabledStatus.value += 1;
                            }
                          });
                        },
                ),
                const SizedBox(height: 12),
                nearbyMerchants.isEmpty
                    ? const NoMerchantCard()
                    : SizedBox(
                        height: 230,
                        child: ListView.separated(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          padding: const EdgeInsetsDirectional.only(
                            start: 10.0,
                            end: 28.0,
                          ),
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 14);
                          },
                          itemCount: nearbyMerchants.length,
                          itemBuilder: (context, index) {
                            var nearbyMerchant = nearbyMerchants[index];
                            return BigTabContainer(
                              bigDistance: nearbyMerchant.distance,
                              bigDiscountGiven:
                                  nearbyMerchant.maxDiscount.toString(),
                              bigMerchantName:
                                  nearbyMerchant.merchantName ?? '......',
                              bigImage:
                                  nearbyMerchant.merchantImageInfoLogoUrl ??
                                      AppImageString.appNoImageURL,
                              // bigLogo:
                              //     nearbyMerchant.merchantImageInfoLogoUrl ??
                              //         nearbyMerchant.merchantImageInfoSlider1 ??
                              //         '',
                              bigOnTap: () {
                                context.pushNamed(
                                  'details-screen',
                                  extra: {
                                    'merchantID': nearbyMerchant.id.toString(),
                                  },
                                ).then((value) {
                                  if (value == true) {
                                    AppVariables.locationEnabledStatus.value +=
                                        1;
                                  }
                                });
                              },
                              // child: Padding(
                              //   padding: EdgeInsets.symmetric(vertical: 6.h),
                              //   child: Text(
                              //     '${toFixed2DecimalPlaces(nearbyMerchant.distance!)} KM Away',
                              //     style: merchantNameStyle.copyWith(
                              //         color: GlobalColors.appColor1),
                              //   ),
                              // ),
                            );
                          },
                        ),
                      ),
              ],
            );
          }
        });
  }
}
