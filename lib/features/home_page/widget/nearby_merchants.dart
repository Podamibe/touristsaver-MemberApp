import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/features/home_page/widget/big_tab_container.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/no_merchant.dart';
import 'package:touristsaver/constants/location_not_enable.dart';
import 'package:touristsaver/features/home_page/services/home_dio.dart';
import 'package:touristsaver/features/home_page/widget/home_section_header.dart';
import 'package:touristsaver/models/request/nearby_req.dart';
import 'package:touristsaver/models/response/nearby_res.dart';

import '../../../constants/app_image_string.dart';
import '../../../constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class NearbyMerchants extends StatefulWidget {
  const NearbyMerchants({super.key, required this.isLoading});

  final bool isLoading;

  @override
  NearbyMerchantsState createState() => NearbyMerchantsState();
}

class NearbyMerchantsState extends State<NearbyMerchants> {
  bool isLoading = false;

  // Calling API of NearByLocation
  Future<NearByLocationResModel?>? nearByRes;
  Future<NearByLocationResModel>? getNearByRes() async {
    NearByLocationResModel nearByLocationResModel = await DioHome().getOffers(
      nearByLocationReqModel: NearByLocationReqModel(
        latitude: AppVariables.latitude,
        longitude: AppVariables.longitude,
        countryCode: AppVariables.countryCode,
      ),
    );
    return nearByLocationResModel;
  }

  @override
  void initState() {
    isLoading = widget.isLoading;
    if (AppVariables.locationEnabledStatus.value > 1) {
      nearByRes = getNearByRes();
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
                  S.of(context).nearbyMerchants,
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
                      S.of(context).nearbyMerchants,
                      style: topicStyle,
                    ),
                  ),
                  const SizedBox(height: 15),
                  LocationNotEnabled(
                      text: S
                          .of(context)
                          .weWantToSetYourActualLocationToShowYouTheMerchantsNearby),
                ],
              );
  }

  // When location is enabled
  locationEnabled() {
    return FutureBuilder<NearByLocationResModel?>(
        future: nearByRes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: AutoSizeText(
                    S.of(context).nearbyMerchants,
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
                    S.of(context).nearbyMerchants,
                    style: topicStyle,
                  ),
                ),
                const SizedBox(height: 15),
                const CustomLoader(itemCount: 2),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeSectionHeader(
                  title: S.of(context).nearbyMerchants,
                  viewAllLabel: S.of(context).viewAll,
                  onViewAllTap: snapshot.data!.data!.isEmpty
                      ? null
                      : () {
                          context.pushNamed('view-all-nearby-merchants');
                        },
                ),
                const SizedBox(height: 12),
                snapshot.data!.data!.isEmpty
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
                          itemCount: snapshot.data!.data!.length,
                          itemBuilder: (context, index) {
                            var nearByData1 = snapshot.data!.data![index];
                            return BigTabContainer(
                              bigDistance: nearByData1.distance,
                              bigDiscountGiven:
                                  nearByData1.maxDiscount.toString(),
                              bigMerchantName:
                                  nearByData1.merchantName ?? '.....',
                              bigImage: nearByData1.merchantImageInfoLogoUrl ??
                                  AppImageString.appNoImageURL,
                              bigOnTap: () {
                                context.pushNamed(
                                  'details-screen',
                                  extra: {
                                    'merchantID': nearByData1.id.toString(),
                                  },
                                ).then((value) {
                                  if (value == true) {
                                    AppVariables.locationEnabledStatus.value +=
                                        1;
                                  }
                                });
                              },
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
