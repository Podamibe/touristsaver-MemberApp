import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/features/home_page/widget/big_tab_container.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/common/widgets/no_merchant.dart';
import 'package:new_piiink/features/home_page/services/home_dio.dart';
import 'package:new_piiink/features/home_page/widget/home_section_header.dart';

import '../../../constants/location_not_enable.dart';
import '../../../constants/style.dart';
import '../../../models/request/nearby_req.dart';
import '../../../models/response/nearby_res.dart';
import 'package:new_piiink/generated/l10n.dart';

class BestOffer extends StatefulWidget {
  const BestOffer({super.key, required this.isLoading});

  final bool isLoading;

  @override
  BestOfferState createState() => BestOfferState();
}

class BestOfferState extends State<BestOffer> {
  bool isLoading = false;

  // Calling API of NearByLocation
  Future<NearByLocationResModel>? bestOfferRes;
  Future<NearByLocationResModel> getBestOfferRes() async {
    NearByLocationResModel nearByLocationResModel =
        await DioHome().getBestOffers(
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
      bestOfferRes = getBestOfferRes();
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
                  S.of(context).bestOffers,
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
                      S.of(context).bestOffers,
                      style: topicStyle,
                    ),
                  ),
                  const SizedBox(height: 15),
                  LocationNotEnabled(
                      text: S
                          .of(context)
                          .weWantToSetYourActualLocationToShowYouTheBestOffersNearby),
                ],
              );
  }

  // When location is enabled
  locationEnabled() {
    return FutureBuilder<NearByLocationResModel?>(
        future: bestOfferRes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: AutoSizeText(
                    S.of(context).bestOffers,
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
                    S.of(context).bestOffers,
                    style: topicStyle,
                  ),
                ),
                const SizedBox(height: 15),
                const CustomLoader(itemCount: 2),
              ],
            );
          } else {
            List<Datum> nearbyMerchants = snapshot.data!.data!;
            nearbyMerchants.sort((a, b) {
              return b.maxDiscount!.compareTo(a.maxDiscount!);
            });
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeSectionHeader(
                  title: S.of(context).bestOffers,
                  viewAllLabel: S.of(context).viewAll,
                  onViewAllTap: nearbyMerchants.isEmpty
                      ? null
                      : () {
                          context.pushNamed('home-view-all', pathParameters: {
                            'appBarName': 'Best Offers'
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
                                  nearbyMerchant.merchantImageInfoLogoUrl ?? '',
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
