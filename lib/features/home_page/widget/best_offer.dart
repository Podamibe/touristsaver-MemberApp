import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/models/merchant_summary.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/common/widgets/merchant_result_tile.dart';
import 'package:new_piiink/common/widgets/no_merchant.dart';
import 'package:new_piiink/features/home_page/services/home_dio.dart';
import 'package:new_piiink/features/home_page/widget/home_section_header.dart';
import 'package:new_piiink/features/merchant/discovery/merchant_discovery_intent.dart';

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
  static const int _homeBestOfferCount = 3;

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
      limit: _homeBestOfferCount,
    );
    return nearByLocationResModel;
  }

  void _loadHomeBestOffers() {
    bestOfferRes = getBestOfferRes();
  }

  @override
  void initState() {
    isLoading = widget.isLoading;
    if (AppVariables.locationEnabledStatus.value > 1) {
      _loadHomeBestOffers();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BestOffer oldWidget) {
    super.didUpdateWidget(oldWidget);
    isLoading = widget.isLoading;
    if (AppVariables.locationEnabledStatus.value > 1 && bestOfferRes == null) {
      _loadHomeBestOffers();
    }
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
              const _BestOffersLoadingIndicator(),
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
                const _BestOffersLoadingIndicator(),
              ],
            );
          } else {
            final List<Datum> nearbyMerchants =
                List<Datum>.from(snapshot.data!.data ?? const <Datum>[]);
            nearbyMerchants.sort((a, b) {
              return (b.maxDiscount ?? 0).compareTo(a.maxDiscount ?? 0);
            });
            final bestOfferMerchants = nearbyMerchants
                .map(MerchantSummaryAdapters.fromNearby)
                .whereType<MerchantSummary>()
                .take(_homeBestOfferCount)
                .toList();
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
                          MerchantDiscoveryIntentStore.launchBestOffers();
                          MerchantDiscoveryIntentStore.requestBottomTab(1);
                          context.goNamed('bottom-bar', pathParameters: {
                            'page': '1',
                          });
                        },
                ),
                const SizedBox(height: 12),
                bestOfferMerchants.isEmpty
                    ? const NoMerchantCard()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemCount: bestOfferMerchants.length,
                          itemBuilder: (context, index) {
                            final merchant = bestOfferMerchants[index];
                            return MerchantResultTile(
                              merchant: merchant,
                              showFavourite: false,
                              onTap: () {
                                context.pushNamed(
                                  'details-screen',
                                  extra: {
                                    'merchantID':
                                        merchant.merchantId.toString(),
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

class _BestOffersLoadingIndicator extends StatelessWidget {
  const _BestOffersLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 72,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Color(0xFF0009FE),
          ),
        ),
      ),
    );
  }
}
