// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/utils.dart';
import 'package:touristsaver/common/services/location_service.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/custom_snackbar.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/no_merchant.dart';
import 'package:touristsaver/common/widgets/touristsaver_loading_view.dart';
import 'package:touristsaver/constants/decimal_remove.dart';
import 'package:touristsaver/constants/fixed_decimal.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/details/bloc/details_blocs.dart';
import 'package:touristsaver/features/details/bloc/details_events.dart';
import 'package:touristsaver/features/details/bloc/details_states.dart';
import 'package:touristsaver/features/details/models/public_deal_presentation.dart';
import 'package:touristsaver/features/details/screens/carousel_widget.dart';
import 'package:touristsaver/features/details/services/dio_detail.dart';
import 'package:touristsaver/features/details/services/fav_or_not.dart';
import 'package:touristsaver/features/discovery_membership/widgets/discovery_savings_limit_sheet.dart';
import 'package:touristsaver/features/payment/services/dio_payment.dart';
import 'package:touristsaver/features/payment/widgets/merchant_claim_proximity_fallback.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/apply_piiink_by_merchant_req.dart';
import 'package:touristsaver/models/response/confirm_piiink_res.dart'
    as confirm_piiink;
import 'package:touristsaver/models/response/detail_res.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../common/app_variables.dart';
import '../../../models/request/mark_fav_req.dart';
import '../../../models/response/common_res.dart';
import '../../merchant/services/dio_merchant.dart';
import 'package:touristsaver/generated/l10n.dart';

import '../../profile/widget/info_popup.dart';
import 'google_map.dart';

class DetailsScreen extends StatefulWidget {
  static const String routeName = '/details-screen';
  final String? merchantID;
  final bool returnToSearch;
  // final bool? isFavorite;

  const DetailsScreen({
    super.key,
    this.merchantID,
    this.returnToSearch = false,
    // this.isFavorite,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF63708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  //For title in Google Map
  String? addressDetail;
  bool isHoursExpanded = false;
  // For image
  List imageList = [];

  //For see more in merchant description
  bool isExpand = false;
  bool? isFavoritez;
  bool isLoading = false;
  bool _isVerifyingMemberDiscount = false;

  Future<void> getFavOrNOt() async {
    FavOrNot? favOrNot =
        await DioDetail().getMerchnatFavOrNot(merchantId: widget.merchantID);
    if (!mounted) return;
    setState(() {
      isFavoritez = favOrNot!.data;
    });
  }

  @override
  void initState() {
    if (AppVariables.accessToken != null) {
      getFavOrNOt();
    }
    // isFavorite = widget.isFavorite;
    super.initState();
  }

  addToFavorites(int merchantId) async {
    var favRes = await DioMerchant().markFavouriteMerchants(
        markFavouriteReqModel: MarkFavouriteReqModel(merchantId: merchantId));
    if (!mounted) return;
    if (favRes is CommonResModel) {
      if (favRes.status == "Success") {
        setState(() {
          isFavoritez = true;
          isLoading = false;
        });
        GlobalSnackBar.showSuccess(
            context, S.of(context).merchantAddedToFavorites);
        return;
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

  removeFromFavorites(int merchantId) async {
    var removeRes =
        await DioMerchant().removeFavouriteMerchants(merchantID: merchantId);
    if (!mounted) return;
    if (removeRes is SecondCommonResModel) {
      if (removeRes.status == "Success") {
        setState(() {
          isFavoritez = false;
          isLoading = false;
        });
        GlobalSnackBar.showSuccess(
            context, S.of(context).merchantRemovedFromFavorites);
        return;
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
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => MerchantDetailBloc(
        RepositoryProvider.of<DioDetail>(context),
        int.parse(widget.merchantID!),
        DateFormat('EEEE').format(
          DateTime.now(),
        ), //For Week Name
        int.parse(
          DateFormat('HH ').format(
            DateTime.now(),
          ), //For 24 hour time format
        ),
      )..add(LoadMerchantDetailEvent()),
      child: BlocBuilder<MerchantDetailBloc, MerchantDetailState>(
        builder: (context, state) {
          if (state is MerchantDetailLoadingState) {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: CustomAppBar(
                  text: '...',
                  icon: Icons.arrow_back_ios,
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              body: const TouristSaverLoadingView(),
            );
          } else if (state is MerchantDetailLoadedState) {
            MerchantDetailResModel merchantDetail = state.merchantDetail;
            MerchantImageInfo? merchantImageInfo =
                merchantDetail.data?.merchantImageInfo;
            if (merchantImageInfo != null) {
              imageList = [
                merchantImageInfo.slider1,
                merchantImageInfo.slider2,
                merchantImageInfo.slider3,
                merchantImageInfo.slider4,
                merchantImageInfo.slider5,
                merchantImageInfo.slider6,
              ];

              imageList.removeWhere((image) {
                return (image == null || image.toString().isEmpty);
              });
            }
            return WillPopScope(
              onWillPop: () async {
                isFavoritez == isFavoritez ? context.pop(true) : context.pop();
                return true;
              },
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
                child: Scaffold(
                  extendBodyBehindAppBar: true,
                  body: IgnorePointer(
                    ignoring: isLoading || _isVerifyingMemberDiscount,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              CarouselWidget(
                                imageList: imageList,
                                heroMode: true,
                                autoPlay: false,
                                heroTitle:
                                    merchantDetail.data!.merchantName ?? '',
                                onBack: () {
                                  isFavoritez == isFavoritez
                                      ? context.pop(true)
                                      : context.pop();
                                },
                              ),
                              SizedBox(height: 10.h),
                              detailPage(merchantDetail),
                            ],
                          ),
                        ),
                        if (_isVerifyingMemberDiscount)
                          const Positioned.fill(
                            child: _MemberDiscountVerificationView(),
                          )
                        else if (isLoading)
                          Positioned(
                            child: Container(
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
                ),
                // floatingActionButton: IgnorePointer(
                //   ignoring: isLoading,
                //   child: FloatingActionButton(
                //     backgroundColor: GlobalColors.appColor1,
                //     onPressed: () {
                //       onClicked(merchantDetail.data!.latlon);
                //     },
                //     child: Image.asset("assets/images/map_button1.png"),
                //   ),
                //   // FloatingActionButton(
                //   //   backgroundColor: GlobalColors.appColor1,
                //   //   onPressed: () {
                //   //     Navigator.push(
                //   //       context,
                //   //       MaterialPageRoute(
                //   //           builder: (context) => GoogleMapMerchant(
                //   //                 latlon: merchantDetail.data!.latlon,
                //   //                 placeTitle: addressDetail,
                //   //               )),
                //   //     );
                //   //   },
                //   //   child: Image.asset("assets/images/map_button1.png"),
                //   // ),
                // ),
              ),
            );
          } else if (state is MerchantDetailErrorState) {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: CustomAppBar(
                  text: S.of(context).error,
                  icon: Icons.arrow_back_ios,
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              body: const SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    CarouselWidget(imageList: []),
                    SizedBox(height: 20),
                    Error1(),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: CustomAppBar(
                  text: S.of(context).error,
                  icon: Icons.arrow_back_ios,
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              body: const SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    CarouselWidget(imageList: []),
                    SizedBox(height: 20),
                    Padding(
                        padding: EdgeInsets.only(top: 200),
                        child: CustomAllLoader1()),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // 1. Builds the dynamic "Open · Closes 6 PM" text
  Widget _buildDynamicHoursHeader(String? rawHours) {
    if (rawHours == null ||
        rawHours.trim().isEmpty ||
        rawHours.toLowerCase() == 'null') {
      return _headerText("Hours not available", "", Colors.black87);
    }
    DateTime now = DateTime.now();
    String fullDay =
        DateFormat('EEEE').format(now).toLowerCase(); // e.g. "monday"
    String shortDay = DateFormat('EEE').format(now).toLowerCase(); // e.g. "mon"

    List<String> lines = rawHours.split('\n');

    String? todayTimeStr;

    // Find the line matching today's day
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].toLowerCase();

      if (line.contains(fullDay) ||
          line.contains(shortDay) ||
          (line.contains('mon') && line.contains('sun')) ||
          (line.contains('mon') &&
              line.contains('fri') &&
              now.weekday >= 1 &&
              now.weekday <= 5) ||
          (line.contains('weekend') && now.weekday >= 6)) {
        int digitIdx = line.indexOf(RegExp(r'\d'));
        if (digitIdx != -1) {
          todayTimeStr = lines[i].substring(digitIdx).trim();
        } else if (i + 1 < lines.length &&
            lines[i + 1].contains(RegExp(r'\d'))) {
          todayTimeStr = lines[i + 1].trim();
        } else if (line.contains('closed')) {
          todayTimeStr = 'closed';
        }
        break;
      }
    }
    if (todayTimeStr == null) {
      return _headerText("Opening Hours", "", Colors.black87);
    }
    if (todayTimeStr.toLowerCase().contains('closed')) {
      return _headerText("Closed", " · Today", const Color(0xFFD93025));
    }

    // Calculate if it's open right now
    try {
      List<String> parts = todayTimeStr.split(RegExp(r'[-–to]'));
      if (parts.length >= 2) {
        String openStr = parts[0].trim();
        String closeStr = parts[1].trim();

        int? openMin = _parseTimeStr(openStr);
        int? closeMin = _parseTimeStr(closeStr);

        if (openMin != null && closeMin != null) {
          int nowMin = now.hour * 60 + now.minute;

          if (closeMin < openMin) closeMin += 24 * 60; // Handle overnight hours
          int checkNowMin = nowMin;
          if (nowMin < openMin && closeMin > 24 * 60) checkNowMin += 24 * 60;

          if (checkNowMin >= openMin && checkNowMin <= closeMin) {
            return _headerText("Open", " · Closes $closeStr",
                const Color(0xFF188038)); // Google Green
          } else {
            return _headerText("Closed", " · Opens $openStr",
                const Color(0xFFD93025)); // Google Red
          }
        }
      }
    } catch (e) {
      debugPrint(" parsing hours: $e");
      // Ignore parsing errors and fallback
    }

    // Fallback if parsing fails but we got the text
    return _headerText("Today", " · $todayTimeStr", Colors.black87);
  }

  // 2. Converts "5:00 pm" or "17:30" to minutes for math
  int? _parseTimeStr(String timeStr) {
    try {
      String clean = timeStr.toLowerCase().trim();
      bool isPm = clean.contains('pm');
      bool isAm = clean.contains('am');
      clean = clean.replaceAll(RegExp(r'[a-z\s]'), '');
      List<String> p = clean.split(':');
      if (p.isEmpty || p[0].isEmpty) return null;

      int h = int.parse(p[0]);
      int m = p.length > 1 ? int.parse(p[1]) : 0;

      if (isPm && h < 12) h += 12;
      if (isAm && h == 12) h = 0;

      return h * 60 + m;
    } catch (e) {
      return null;
    }
  }

  // 3. Formats the RichText nicely
  Widget _headerText(String status, String suffix, Color statusColor) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: status,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  fontFamily: 'Sans')),
          TextSpan(
              text: suffix,
              style: TextStyle(
                  color: Colors.black87, fontSize: 16.sp, fontFamily: 'Sans')),
        ],
      ),
    );
  }

  // 4. Builds the expanded list of all days
  Widget _buildOpeningHoursList(MerchantDetailResModel merchantDetail) {
    String? rawOpeningHours =
        merchantDetail.data?.merchantWebsiteInfo?.openingHourInfo;
    String textToDisplay = (rawOpeningHours == null ||
            rawOpeningHours.trim().isEmpty ||
            rawOpeningHours.trim().toLowerCase() == 'null')
        ? S.of(context).noOpeningHours
        : rawOpeningHours;

    List<Widget> hoursListWidgets = [];
    if (textToDisplay == S.of(context).noOpeningHours) {
      hoursListWidgets
          .add(Text(textToDisplay, style: TextStyle(fontSize: 14.sp)));
    } else {
      List<String> lines = textToDisplay.split('\n');
      String? pendingDay;

      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;
        int firstDigitIndex = line.indexOf(RegExp(r'\d'));

        if (firstDigitIndex != -1) {
          String leftPart = line
              .substring(0, firstDigitIndex)
              .replaceAll(RegExp(r'[:-]'), '')
              .trim();
          String rightPart = line.substring(firstDigitIndex).trim();

          if (pendingDay != null) {
            leftPart = pendingDay + (leftPart.isNotEmpty ? ' $leftPart' : '');
            pendingDay = null;
          }

          if (rightPart.isNotEmpty) {
            hoursListWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(leftPart,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87))),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 3,
                        child: Text(rightPart,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black.withValues(alpha: 0.7)))),
                  ],
                ),
              ),
            );
          }
        } else {
          if (i + 1 < lines.length && lines[i + 1].contains(RegExp(r'\d'))) {
            pendingDay = line;
          } else {
            hoursListWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  line.trim(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: line.toLowerCase().contains('closed')
                        ? Colors.red.withValues(alpha: 0.8)
                        : Colors.black.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            );
          }
        }
      }
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: hoursListWidgets);
  }

  Widget _buildPublicDealHoursHeader(String? rawHours) {
    final PublicDealOpeningHoursRow today =
        publicDealHoursForWeekday(rawHours, DateTime.now().weekday);
    return _headerText('Today', ' · ${today.value}', Colors.black87);
  }

  Widget _buildPublicDealOpeningHoursList(String? rawHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parsePublicDealOpeningHours(rawHours)
          .map((PublicDealOpeningHoursRow row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.weekday,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: row.value.toLowerCase() == 'closed'
                              ? Colors.red.withValues(alpha: 0.8)
                              : Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(growable: false),
    );
  }

//For locating merchant in google map
  onClicked(List<double>? latlang) async {
    if (!_hasLatLon(latlang)) {
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
      return;
    }
    double lat = latlang![0];
    double lon = latlang[1];
    final String destination = '$lat,$lon';
    final Uri appleUri = Uri.https('maps.apple.com', '/', {
      'saddr': 'Current Location',
      'daddr': destination,
      'directionsmode': 'driving',
    });
    final Uri googleUri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': 'Current Location',
      'destination': destination,
      'travelmode': 'driving',
    });

    if (Platform.isIOS) {
      if (await canLaunchUrl(appleUri)) {
        await launchUrl(appleUri, mode: LaunchMode.externalApplication);
      } else {
        if (await canLaunchUrl(googleUri)) {
          await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        }
      }
    } else {
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  // Detail Page
  bool _isDiscountOfferListing(Data? merchant) {
    return merchant?.merchantListingType?.trim().toLowerCase() ==
        'discount_offer';
  }

  bool _isPublicDealListing(Data? merchant) {
    return usesPublicDealPresentation(merchant?.merchantListingType);
  }

  String _publicListingLabel(String? listingType) {
    switch (listingType?.trim().toLowerCase()) {
      case 'public_deal':
        return 'Dining Deal';
      case 'concierge_listing':
        return 'Concierge listing';
      default:
        return 'Concierge listing';
    }
  }

  Future<void> _openExternalUrl(String externalUrl) async {
    final Uri? uri = Uri.tryParse(prefixHttp(externalUrl.trim()));
    if (uri == null || !uri.hasScheme) {
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
      return;
    }

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
      }
    } catch (e) {
      if (!mounted) return;
      GlobalSnackBar.showError(context, S.of(context).somethingWentWrong);
    }
  }

  Widget _favoriteButton() {
    if (AppVariables.accessToken == null) return const SizedBox.shrink();
    return isLoading
        ? const SizedBox(
            width: 34,
            height: 34,
            child: FittedBox(child: CustomAllLoader1()),
          )
        : IconButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              int merchantId = int.parse(widget.merchantID!);
              isFavoritez == true
                  ? removeFromFavorites(merchantId)
                  : addToFavorites(merchantId);
            },
            icon: Icon(
              isFavoritez == true ? Icons.favorite : Icons.favorite_border,
            ),
            color: _primaryBlue,
            tooltip: 'Save offer',
          );
  }

  String? _memberDiscountValue(Data? merchant) {
    String? formatDiscount(double? value) {
      if (value == null || value <= 0) return null;
      return removeTrailingZero(value.toString());
    }

    return formatDiscount(merchant?.discountAtHourOfDay) ??
        formatDiscount(merchant?.maxDiscount);
  }

  Widget _memberOfferCard(MerchantDetailResModel merchantDetail) {
    final String? discount = _memberDiscountValue(merchantDetail.data);
    final String offerCopy = discount == null
        ? 'Save when paying your bill'
        : 'Save $discount% when paying your bill';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A236B).withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF7FF),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(
                    Icons.local_offer_outlined,
                    color: _primaryBlue,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Member Offer',
                        style: TextStyle(
                          color: _headingColor,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Sans',
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        offerCopy,
                        style: TextStyle(
                          color: _bodyColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                _favoriteButton(),
              ],
            ),
            if (AppVariables.accessToken != null) ...[
              SizedBox(height: 14.h),
              _primaryGradientButton(
                label: 'Claim Discount',
                onTap: () => _showDirectClaimBillAmountSheet(merchantDetail),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _memberOfferActions(MerchantDetailResModel merchantDetail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: _secondaryOutlineButton(
              label: S.of(context).moreOffers,
              onTap: () {
                context.pushNamed('more-offers', extra: {
                  'argImageList': imageList,
                  'merchantID': widget.merchantID,
                });
              },
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _secondaryOutlineButton(
              label: S.of(context).reviews,
              onTap: () {
                context.pushNamed(
                  'merchant-rating',
                  extra: {
                    'merchantId': widget.merchantID,
                    'merchantName': merchantDetail.data?.merchantName,
                    'merchantLogo':
                        merchantDetail.data?.merchantImageInfo?.logoUrl ??
                            merchantDetail.data?.merchantImageInfo?.slider1 ??
                            merchantDetail.data?.merchantImageInfo?.slider2,
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDirectClaimBillAmountSheet(
      MerchantDetailResModel merchantDetail,
      {double? initialAmount}) async {
    if (isLoading || _isVerifyingMemberDiscount) return;

    final double? billAmount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BillAmountBottomSheet(
          currencySymbol: AppVariables.currency ?? '\$',
          initialAmount: initialAmount,
        );
      },
    );

    if (!mounted || billAmount == null) return;
    await _startDirectMerchantClaim(
      merchantDetail: merchantDetail,
      billAmount: billAmount,
    );
  }

  Future<void> _startDirectMerchantClaim({
    required MerchantDetailResModel merchantDetail,
    required double billAmount,
  }) async {
    if (isLoading || _isVerifyingMemberDiscount) return;

    final Data? merchant = merchantDetail.data;
    final int? merchantId = merchant?.id;
    if (merchant == null || merchantId == null) {
      GlobalSnackBar.showError(
        context,
        'This merchant discount cannot be claimed from the profile yet. Please use the QR scan option.',
      );
      return;
    }

    setState(() {
      _isVerifyingMemberDiscount = true;
    });

    final ClaimLocation claimLocation =
        await LocationService().getCurrentClaimLocation();
    if (!mounted) return;

    final results = await Future.wait<dynamic>([
      DioPay().startApplyPiiinkByMerchant(
        applyPiiinkByMerchantReqModel: ApplyPiiinkByMerchantReqModel(
          merchantId: merchantId,
          amount: billAmount,
          lang: AppVariables.selectedLanguageNow,
          latitude: claimLocation.latitude,
          longitude: claimLocation.longitude,
        ),
      ),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);

    final res = results.first;

    if (!mounted) return;

    if (res is confirm_piiink.ConfirmApplyPiiinkResModel &&
        res.status == 'Success' &&
        res.data != null) {
      final data = res.data!;
      setState(() {
        _isVerifyingMemberDiscount = false;
      });
      final dynamic editResult = await context.pushNamed(
        'confirm-pay',
        extra: {
          'merchantId': data.merchantInfo?.id ?? merchant.id,
          'totalAmount': billAmount.toStringAsFixed(2),
          'qrCode': '',
          'isProfileClaim': true,
          'hasMerchantPiiinks': data.hasMerchantPiiinks.toString(),
          'hasUniversalPiiinks': data.hasUniversalPiiinks.toString(),
          'merchantName': data.merchantInfo?.merchantName ??
              merchant.merchantName ??
              'Merchant',
          'universalPiiinkBalance':
              toFixed2DecimalPlaces(data.universalPiiinkBalance ?? 0),
          'merchantPiiinkBalance':
              toFixed2DecimalPlaces(data.merchantPiiinkBalance ?? 0),
          'merchantRebateToMember': data.merchantRebateToMember.toString(),
          'merchantDiscountPercentage':
              data.merchantDiscountPercentage.toString(),
          'discountedTransactionAmount':
              data.discountedTransactionAmount.toString(),
          'totalPiiinkDiscount': data.totalPiiinkDiscount.toString(),
          'discoverySavingsMessage': data.discoverySavingsAdjustment?.message,
          'logo': _merchantLogoFromDetail(merchant),
          'universalPiiinkOnHold': data.universalPiiinkBalanceOnHold.toString(),
          'merchantPiiinkOnHold': data.merchantPiiinkBalanceOnHold.toString(),
          'returnToSearch': widget.returnToSearch,
          'claimLatitude': claimLocation.latitude,
          'claimLongitude': claimLocation.longitude,
        },
      );
      if (!mounted) return;
      final double? editAmount = _profileClaimEditAmount(editResult);
      if (editAmount != null) {
        await _showDirectClaimBillAmountSheet(
          merchantDetail,
          initialAmount: editAmount,
        );
      }
      return;
    }

    setState(() {
      _isVerifyingMemberDiscount = false;
    });

    final MerchantClaimProximityFailure? proximityFailure =
        MerchantClaimProximityFailure.fromResponse(res);
    if (proximityFailure != null) {
      final String merchantName = merchant.merchantName ?? 'this merchant';
      final bool scanQr = await showMerchantClaimProximityFallback(
        context: context,
        merchantName: merchantName,
      );
      if (!mounted || !scanQr) return;
      _openExistingMerchantQrFlow(
        merchantName: merchantName,
        billAmount: billAmount,
      );
      return;
    }

    if (await showDiscoverySavingsLimitSheetForResponse(
      context: context,
      response: res,
    )) {
      return;
    }
    if (!mounted) return;

    GlobalSnackBar.showError(
      context,
      _directClaimErrorMessage(res) ??
          'The discount could not be created. Please try again or use the QR scan option.',
    );
  }

  void _openExistingMerchantQrFlow({
    required String merchantName,
    required double billAmount,
  }) {
    context.pushNamed(
      'pay',
      extra: merchantClaimQrRouteExtra(
        merchantName: merchantName,
        amount: billAmount.toStringAsFixed(2),
        returnToSearch: widget.returnToSearch,
      ),
    );
  }

  double? _profileClaimEditAmount(dynamic result) {
    if (result is Map) {
      final Object? editRequested = result['editRequested'];
      if (editRequested != true) return null;
      final Object? amount = result['billAmount'];
      if (amount is num) return amount.toDouble();
      if (amount is String) return double.tryParse(amount);
    }
    return null;
  }

  String? _directClaimErrorMessage(dynamic res) {
    if (res is ErrorResModel) {
      final String? message = res.message ?? res.error?.status?.toString();
      if (message == null || message.trim().isEmpty) return null;
      return message;
    }
    return null;
  }

  String? _merchantLogoFromDetail(Data merchant) {
    final MerchantImageInfo? imageInfo = merchant.merchantImageInfo;
    return _firstNotEmpty([
      imageInfo?.logoUrl,
      imageInfo?.slider1,
      imageInfo?.slider2,
      imageInfo?.slider3,
      imageInfo?.slider4,
      imageInfo?.slider5,
      imageInfo?.slider6,
    ]);
  }

  String? _firstNotEmpty(Iterable<String?> values) {
    for (final String? value in values) {
      final String? trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  Widget _venueInfoHeader(String? websiteUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Venue Info',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _headingColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
        ),
        if (websiteUrl != null) ...[
          SizedBox(width: 12.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => _openExternalUrl(websiteUrl),
              child: Ink(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF48F100),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF111C44).withValues(alpha: 0.16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF48F100).withValues(alpha: 0.26),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'View Website',
                  style: TextStyle(
                    color: const Color(0xFF071126),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _publicListingCard(MerchantDetailResModel merchantDetail) {
    final Data? merchant = merchantDetail.data;
    final bool isPublicDealListing = _isPublicDealListing(merchant);
    final String? description =
        merchant?.merchantWebsiteInfo?.merchantDescription;
    final bool hasDescription =
        description != null && description.trim().isNotEmpty;
    final String? externalUrl = merchant?.externalUrl;
    final bool hasExternalUrl =
        externalUrl != null && externalUrl.trim().isNotEmpty;
    final String? websiteUrl = isPublicDealListing
        ? usableMerchantWebsite(merchant?.merchantWebsiteInfo?.websiteLink)
        : null;
    final String ctaLabel =
        merchant?.externalUrlLabel?.trim().isNotEmpty == true
            ? merchant!.externalUrlLabel!.trim()
            : 'View offer';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A236B).withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF7FF),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: _primaryBlue,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _publicListingLabel(merchant?.merchantListingType),
                        style: TextStyle(
                          color: _headingColor,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Sans',
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        merchant?.merchantName ?? '',
                        style: TextStyle(
                          color: _bodyColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                _favoriteButton(),
              ],
            ),
            SizedBox(height: 15.h),
            isPublicDealListing
                ? _venueInfoHeader(websiteUrl)
                : Text(
                    S.of(context).additionalInformation,
                    style: TextStyle(
                      color: _headingColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Sans',
                    ),
                  ),
            SizedBox(height: 8.h),
            hasDescription
                ? isPublicDealListing
                    ? _venueInfoDescriptionHtml(description)
                    : _descriptionHtml(description)
                : NoMerchantCard(text: S.of(context).noMerchantDescription),
            if (hasExternalUrl && !isPublicDealListing) ...[
              SizedBox(height: 16.h),
              _primaryGradientButton(
                label: ctaLabel,
                onTap: () => _openExternalUrl(externalUrl),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _venueSpecialsSection(MerchantDetailResModel merchantDetail) {
    final List<DiningDealOffer> specials =
        merchantDetail.data?.publishedDiningDealOffers ?? const [];
    if (specials.isEmpty) return const SizedBox.shrink();

    return Padding(
      key: const ValueKey('venue-specials-section'),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText('Venue Specials', style: topicStyle),
          SizedBox(height: 10.h),
          for (int index = 0; index < specials.length; index++) ...[
            _venueSpecialCard(specials[index], merchantDetail.data?.country),
            if (index != specials.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  Widget _venueSpecialCard(DiningDealOffer special, Country? country) {
    final String? schedule = _venueSpecialSchedule(special);
    final String? price = _venueSpecialPrice(special, country);
    final String? description = special.description?.trim();
    final String? conditions = special.conditions?.trim();
    final String? sourceUrl = special.sourceUrl?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A236B).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            special.title?.trim().isNotEmpty == true
                ? special.title!.trim()
                : 'Dining deal',
            style: TextStyle(
              color: _headingColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
            ),
          ),
          if (schedule != null || price != null) ...[
            SizedBox(height: 7.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (schedule != null)
                  _venueSpecialFact(Icons.schedule_rounded, schedule),
                if (price != null)
                  _venueSpecialFact(Icons.payments_outlined, price),
              ],
            ),
          ],
          if (description != null && description.isNotEmpty) ...[
            SizedBox(height: 9.h),
            Text(
              description,
              style: TextStyle(
                color: _bodyColor,
                fontSize: 13.sp,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (conditions != null && conditions.isNotEmpty) ...[
            SizedBox(height: 7.h),
            Text(
              conditions,
              style: TextStyle(
                color: _bodyColor,
                fontSize: 12.sp,
                height: 1.35,
              ),
            ),
          ],
          if (special.bookingRequired) ...[
            SizedBox(height: 7.h),
            Text(
              'Booking required',
              style: TextStyle(
                color: _headingColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (sourceUrl != null && sourceUrl.isNotEmpty) ...[
            SizedBox(height: 8.h),
            InkWell(
              onTap: () => _openExternalUrl(sourceUrl),
              borderRadius: BorderRadius.circular(6.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Text(
                  'Offer details',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                    decorationColor: _primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _venueSpecialFact(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: _primaryBlue),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: _headingColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String? _venueSpecialSchedule(DiningDealOffer special) {
    final String? day = special.dayOfWeek?.trim();
    final String? start = _formatOfferTime(special.startTime);
    final String? end = _formatOfferTime(special.endTime);
    final String? time = start == null
        ? end
        : end == null
            ? start
            : '$start–$end';
    if (day == null || day.isEmpty) return time;
    final String formattedDay =
        '${day[0].toUpperCase()}${day.substring(1).toLowerCase()}';
    return time == null ? formattedDay : '$formattedDay · $time';
  }

  String? _formatOfferTime(String? value) {
    final String? time = value?.trim();
    if (time == null || time.isEmpty) return null;
    for (final String pattern in const ['HH:mm:ss', 'HH:mm']) {
      try {
        final DateTime parsedTime = DateFormat(pattern).parseStrict(time);
        return DateFormat('h:mm a').format(parsedTime);
      } on FormatException {
        // Try the next supported backend time format.
      }
    }
    return time;
  }

  String? _venueSpecialPrice(DiningDealOffer special, Country? country) {
    final double? offerPrice = special.offerPrice;
    final double? regularPrice = special.regularPrice;
    if (offerPrice == null && regularPrice == null) return null;
    final String symbol = country?.currencySymbol?.trim().isNotEmpty == true
        ? country!.currencySymbol!.trim()
        : r'$';
    final bool prefix = country?.symbolIsPrefix != false;
    String format(double value) {
      final String amount = value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(2);
      return prefix ? '$symbol$amount' : '$amount $symbol';
    }

    if (offerPrice == null) return 'Usually ${format(regularPrice!)}';
    if (regularPrice == null || regularPrice <= offerPrice) {
      return format(offerPrice);
    }
    return '${format(offerPrice)} · usually ${format(regularPrice)}';
  }

  Widget _primaryGradientButton({
    required String label,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Ink(
          height: subtitle == null ? 50.h : 58.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primaryBlue, _ctaCyan],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: _primaryBlue.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sans',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryOutlineButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15.r),
        onTap: onTap,
        child: Ink(
          height: 46.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: _primaryBlue.withValues(alpha: 0.55)),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _headingColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Sans',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactCircleIcon(
    IconData icon, {
    bool enabled = true,
    double size = 32,
    double iconSize = 18,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: enabled ? _primaryBlue : const Color(0xffb0b0b0),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  bool _hasLatLon(List<double>? latlon) {
    return latlon != null && latlon.length >= 2;
  }

  String _merchantAddress(Data? merchant) {
    final String? stateName = merchant?.state?.stateName;
    final bool showState =
        stateName != null && stateName.toLowerCase() != 'unallocated';
    final List<String> addressParts = [
      [
        merchant?.buildingNo,
        merchant?.streetInfo,
      ]
          .where((part) => part != null && part.trim().isNotEmpty)
          .map((part) => part!.trim())
          .join(' '),
      merchant?.city,
      if (showState) stateName,
      merchant?.postalCodeUser?.toString(),
      merchant?.country?.countryName,
    ].where((part) => part != null && part.trim().isNotEmpty).map((part) {
      return part!.trim();
    }).toList();

    return addressParts.join(', ');
  }

  Map<String, Style> get _compactDescriptionHtmlStyle {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        lineHeight: LineHeight.number(1.12),
        color: _bodyColor,
        fontSize: FontSize(14.sp),
      ),
      'p': Style(
        margin: Margins.only(bottom: 6),
        lineHeight: LineHeight.number(1.12),
      ),
    };
  }

  Future<void> _openHtmlLink(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    if (Platform.isIOS) {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrlString(
        url,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    }
  }

  Widget _descriptionHtml(String description) {
    if (description.length <= 200) {
      return Html(
        style: _compactDescriptionHtmlStyle,
        data: description,
        onLinkTap: (url, _, __) => _openHtmlLink(url),
      );
    }

    return Column(
      children: [
        Html(
          style: _compactDescriptionHtmlStyle,
          data: isExpand == false
              ? '${description.substring(0, 200)}..'
              : description,
          onLinkTap: (url, _, __) => _openHtmlLink(url),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpand = !isExpand;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AutoSizeText(
                isExpand == false
                    ? S.of(context).seeMore
                    : S.of(context).seeLess,
                style: viewAllStyle.copyWith(
                  color: _primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.5),
                child: Icon(
                  isExpand == false ? Icons.expand_more : Icons.expand_less,
                  color: _primaryBlue,
                  size: 20,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _venueInfoDescriptionHtml(String description) {
    const int collapsedLines = 7;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final String lineAwareHtml = description
            .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
            .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n');
        final String plainText = HtmlParser.parseHTML(lineAwareHtml).text;
        final TextPainter painter = TextPainter(
          text: TextSpan(
            text: plainText,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.12,
            ),
          ),
          maxLines: collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final bool exceedsCollapsedLines = painter.didExceedMaxLines;

        if (!exceedsCollapsedLines) {
          return Html(
            style: _compactDescriptionHtmlStyle,
            data: description,
            onLinkTap: (url, _, __) => _openHtmlLink(url),
          );
        }

        return Column(
          children: [
            if (isExpand)
              Html(
                style: _compactDescriptionHtmlStyle,
                data: description,
                onLinkTap: (url, _, __) => _openHtmlLink(url),
              )
            else
              Text(
                plainText,
                maxLines: collapsedLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _bodyColor,
                  fontSize: 14.sp,
                  height: 1.12,
                ),
              ),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpand = !isExpand;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    isExpand == false
                        ? S.of(context).seeMore
                        : S.of(context).seeLess,
                    style: viewAllStyle.copyWith(
                      color: _primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.5),
                    child: Icon(
                      isExpand == false ? Icons.expand_more : Icons.expand_less,
                      color: _primaryBlue,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  detailPage(MerchantDetailResModel merchantDetail) {
    //Getting address
    addressDetail = _merchantAddress(merchantDetail.data);

    //To open the dial pad of the phone
    final bool isPublicDealListing = _isPublicDealListing(merchantDetail.data);
    final String? publicDealPhone = isPublicDealListing
        ? usablePublicDealPhone(merchantDetail.data?.merchantPhoneNumber)
        : null;
    final bool showOpeningHours = !isPublicDealListing ||
        parsePublicDealOpeningHours(
                merchantDetail.data?.merchantWebsiteInfo?.openingHourInfo)
            .isNotEmpty;

    callNum() async {
      final String phone = publicDealPhone ??
          merchantDetail.data!.merchantPhoneNumber.toString();
      Uri phoneno = Uri.parse('tel:$phone');
      await launchUrl(phoneno);
    }

    //To open the website link
    openWeb() async {
      String prefixedUrl = prefixHttp(
          merchantDetail.data!.merchantWebsiteInfo!.websiteLink.toString());
      Uri webOpen = Uri.parse(prefixedUrl);
      await launchUrl(webOpen,
          mode: Platform.isIOS
              ? LaunchMode.externalApplication
              : LaunchMode.externalNonBrowserApplication);
    }

    //To open the facebook link
    openFacebook() async {
      try {
        //For opening in web view
        String prefixedUrl =
            prefixHttp(merchantDetail.data!.merchantWebsiteInfo!.facebookLink!);
        Uri webFacebook = Uri.parse(prefixedUrl);
        await launchUrl(webFacebook,
            mode: Platform.isIOS
                ? LaunchMode.externalApplication
                : LaunchMode.externalNonBrowserApplication);
      } catch (e) {
        GlobalSnackBar.showError(context, S.of(context).cannotOpenFacebook);
      }
    }

    //To open the instagram link
    openInstagram() async {
      // String profileLink = instagramSiteLink(
      //     merchantDetail.data!.merchantWebsiteInfo!.instagramLink!);
      // String appInstagram;
      // appInstagram = 'instagram://user?username=$profileLink';
      try {
        // Uri nativeInstagram = Uri.parse(appInstagram);
        // var canLaunchNatively = await canLaunchUrl(nativeInstagram);
        // if (canLaunchNatively) {
        //   launchUrlString(appInstagram);
        // } else {
        String prefixedUrl = prefixHttp(
            merchantDetail.data!.merchantWebsiteInfo!.instagramLink!);
        Uri webInstagram = Uri.parse(prefixedUrl);
        await launchUrl(webInstagram,
            mode: Platform.isIOS
                ? LaunchMode.externalApplication
                : LaunchMode.externalNonBrowserApplication);
        // }
      } catch (e) {
        GlobalSnackBar.showError(context, S.of(context).cannotOpenInstagram);
      }
    }

    //To open the email link
    openEmail() async {
      Uri emailOpen = Uri.parse('mailto:${merchantDetail.data!.merchantEmail}');
      await launchUrl(emailOpen);
    }

    final bool isDiscountOfferListing =
        _isDiscountOfferListing(merchantDetail.data);
    final bool usesStandardVenuePresentation =
        usesStandardVenueInfoPresentation(
            merchantDetail.data?.merchantListingType);
    final String? venueWebsiteUrl = usesStandardVenuePresentation
        ? usableMerchantWebsite(
            merchantDetail.data?.merchantWebsiteInfo?.websiteLink)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isDiscountOfferListing
            ? _memberOfferCard(merchantDetail)
            : _publicListingCard(merchantDetail),
        if (!isPublicDealListing) SizedBox(height: 12.h),
        if (isDiscountOfferListing &&
            merchantDetail.data!.publishedDiningDealOffers.isNotEmpty) ...[
          _venueSpecialsSection(merchantDetail),
          SizedBox(height: 20.h),
        ],
        if (isDiscountOfferListing) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _venueInfoHeader(venueWebsiteUrl),
          ),
          const SizedBox(height: 10),
          Center(
            child: merchantDetail.data?.merchantWebsiteInfo == null
                ? NoMerchantCard(text: S.of(context).noMerchantDescription)
                : merchantDetail
                            .data!.merchantWebsiteInfo?.merchantDescription ==
                        null
                    ? NoMerchantCard(text: S.of(context).noMerchantDescription)
                    : merchantDetail.data!.merchantWebsiteInfo
                                ?.merchantDescription ==
                            ''
                        ? NoMerchantCard(
                            text: S.of(context).noMerchantDescription)
                        : Container(
                            width: MediaQuery.of(context).size.width / 1.05,
                            constraints: const BoxConstraints(
                                //To make height expandable according to the text
                                maxHeight: double.infinity),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                                color: GlobalColors.appWhiteBackgroundColor,
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(color: _borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0A236B)
                                        .withValues(alpha: 0.05),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8),
                                  )
                                ]),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            child: _venueInfoDescriptionHtml(
                              merchantDetail.data!.merchantWebsiteInfo!
                                  .merchantDescription
                                  .toString(),
                            ),
                          ),
          ),
          SizedBox(height: 14.h),
          _memberOfferActions(merchantDetail),
        ],
        SizedBox(height: usesStandardVenuePresentation ? 16.h : 20.0),
        if (!usesStandardVenuePresentation) ...[
          // Contact
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: AutoSizeText(
              S.of(context).contact,
              style: topicStyle,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Center(
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: double.infinity,
            ),
            // width: MediaQuery.of(context).size.width / 1.05,
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
                color: GlobalColors.appWhiteBackgroundColor,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(2, 2),
                  )
                ]),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (showOpeningHours) ...[
                  // Opening Hours
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isHoursExpanded = !isHoursExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: _contactCircleIcon(
                                  Icons.access_time_filled,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Dynamic Header (Open/Closed)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    isPublicDealListing
                                        ? _buildPublicDealHoursHeader(
                                            merchantDetail
                                                .data
                                                ?.merchantWebsiteInfo
                                                ?.openingHourInfo)
                                        : _buildDynamicHoursHeader(
                                            merchantDetail
                                                .data
                                                ?.merchantWebsiteInfo
                                                ?.openingHourInfo),
                                    const SizedBox(height: 4),
                                    Text(
                                      isHoursExpanded
                                          ? "Hide hours"
                                          : "See more hours",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Dropdown Chevron
                              Icon(
                                isHoursExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: _primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Smooth Expanding List
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: isHoursExpanded
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 36.0,
                                    bottom:
                                        10.0), // Indents text to match header
                                child: isPublicDealListing
                                    ? _buildPublicDealOpeningHoursList(
                                        merchantDetail.data?.merchantWebsiteInfo
                                            ?.openingHourInfo)
                                    : _buildOpeningHoursList(merchantDetail),
                              )
                            : const SizedBox(width: double.infinity, height: 0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    _contactCircleIcon(Icons.directions_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          onClicked(merchantDetail.data?.latlon);
                        },
                        child: AutoSizeText(
                          S.of(context).direction,
                          style: const TextStyle(
                            shadows: [
                              Shadow(color: Colors.black, offset: Offset(0, -5))
                            ],
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.transparent,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            decorationThickness: 1,
                            decorationStyle: TextDecorationStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isPublicDealListing || publicDealPhone != null) ...[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _contactCircleIcon(Icons.phone_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: merchantDetail.data?.merchantPhoneNumber == ''
                              ? () {}
                              : merchantDetail.data?.merchantPhoneNumber != null
                                  ? callNum
                                  : () {},
                          child: AutoSizeText(
                            merchantDetail.data?.merchantPhoneNumber == ''
                                ? S.of(context).noNumber
                                : "${merchantDetail.data?.merchantPhoneNumber == null ? '' : merchantDetail.data?.country!.phonePrefix} ${merchantDetail.data?.merchantPhoneNumber ?? 'No Number'}",
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                    color: Colors.black, offset: Offset(0, -5))
                              ],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.transparent,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black,
                              decorationThickness: 1,
                              decorationStyle: TextDecorationStyle.solid,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 15),

                // // Address
                InkWell(
                  onTap: () {
                    if (!_hasLatLon(merchantDetail.data?.latlon)) {
                      GlobalSnackBar.showError(
                          context, S.of(context).somethingWentWrong);
                      return;
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoogleMapMerchant(
                                  latlon: merchantDetail.data?.latlon,
                                  placeTitle: addressDetail,
                                )));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _contactCircleIcon(Icons.location_on_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AutoSizeText(
                          // '31 Sportsmans Parade, Bokarina QLD 4575, Nepal
                          addressDetail!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Row(
                //   children: [
                //     Container(
                //       width: 25,
                //       height: 25,
                //       decoration: const BoxDecoration(
                //           shape: BoxShape.circle, color: GlobalColors.appColor),
                //       child: const Icon(Icons.alternate_email,
                //           size: 15, color: Colors.white),
                //     ),
                //     const SizedBox(width: 10),
                //     Expanded(
                //       child: GestureDetector(
                //         onTap: merchantDetail.data?.merchantEmail == ''
                //             ? () {}
                //             : merchantDetail.data?.merchantEmail != null
                //                 ? openEmail
                //                 : () {},
                //         child: AutoSizeText(
                //           merchantDetail.data?.merchantEmail == ''
                //               ? S.of(context).noEmail
                //               : merchantDetail.data?.merchantEmail ??
                //                   S.of(context).noEmail,
                //           style: const TextStyle(
                //             shadows: [
                //               Shadow(color: Colors.black, offset: Offset(0, -5))
                //             ],
                //             fontSize: 15,
                //             fontWeight: FontWeight.w500,
                //             color: Colors.transparent,
                //             decoration: TextDecoration.underline,
                //             decorationColor: Colors.black,
                //             decorationThickness: 1,
                //             decorationStyle: TextDecorationStyle.solid,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                if (!isPublicDealListing) ...[
                  const SizedBox(height: 25),
                  // Facebook / Instagram / Website / Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: merchantDetail.data?.merchantWebsiteInfo == null
                            ? () {
                                dialogInfo(S.of(context).noFacebookLink);
                              }
                            : merchantDetail.data?.merchantWebsiteInfo
                                        ?.facebookLink ==
                                    ''
                                ? () {
                                    dialogInfo(S.of(context).noFacebookLink);
                                  }
                                : merchantDetail.data?.merchantWebsiteInfo
                                            ?.facebookLink !=
                                        null
                                    ? openFacebook
                                    : () {
                                        dialogInfo(
                                            S.of(context).noFacebookLink);
                                      },
                        child: Column(
                          children: [
                            _contactCircleIcon(
                              FontAwesomeIcons.facebookF,
                              enabled: merchantDetail.data?.merchantWebsiteInfo
                                          ?.facebookLink !=
                                      '' &&
                                  merchantDetail.data?.merchantWebsiteInfo
                                          ?.facebookLink !=
                                      null,
                              size: 50,
                              iconSize: 24,
                            ),
                            const SizedBox(height: 10),
                            AutoSizeText(S.of(context).facebook,
                                style: dopdownTextStyle),
                          ],
                        ),
                      ),

                      //Instagram
                      GestureDetector(
                        onTap: merchantDetail.data?.merchantWebsiteInfo == null
                            ? () {
                                dialogInfo(S.of(context).noInstagramLink);
                              }
                            : merchantDetail.data?.merchantWebsiteInfo
                                        ?.instagramLink ==
                                    ''
                                ? () {
                                    dialogInfo(S.of(context).noInstagramLink);
                                  }
                                : merchantDetail.data?.merchantWebsiteInfo
                                            ?.instagramLink !=
                                        null
                                    ? openInstagram
                                    : () {
                                        dialogInfo(
                                            S.of(context).noInstagramLink);
                                      },
                        child: Column(
                          children: [
                            _contactCircleIcon(
                              FontAwesomeIcons.instagram,
                              enabled: merchantDetail.data?.merchantWebsiteInfo
                                          ?.instagramLink !=
                                      '' &&
                                  merchantDetail.data?.merchantWebsiteInfo
                                          ?.instagramLink !=
                                      null,
                              size: 50,
                              iconSize: 25,
                            ),
                            const SizedBox(height: 10),
                            AutoSizeText(S.of(context).instagram,
                                style: dopdownTextStyle),
                          ],
                        ),
                      ),

                      //Website
                      GestureDetector(
                        onTap: merchantDetail.data?.merchantWebsiteInfo == null
                            ? () {
                                dialogInfo(S.of(context).noWebsiteLink);
                              }
                            : merchantDetail.data?.merchantWebsiteInfo
                                        ?.websiteLink ==
                                    ''
                                ? () {
                                    dialogInfo(S.of(context).noWebsiteLink);
                                  }
                                : merchantDetail.data?.merchantWebsiteInfo
                                            ?.websiteLink !=
                                        null
                                    ? openWeb
                                    : () {
                                        dialogInfo(S.of(context).noWebsiteLink);
                                      },
                        child: Column(
                          children: [
                            _contactCircleIcon(
                              Icons.language,
                              enabled: merchantDetail.data?.merchantWebsiteInfo
                                          ?.websiteLink !=
                                      '' &&
                                  merchantDetail.data?.merchantWebsiteInfo
                                          ?.websiteLink !=
                                      null,
                              size: 50,
                              iconSize: 27,
                            ),
                            const SizedBox(height: 10),
                            AutoSizeText(S.of(context).website,
                                style: dopdownTextStyle),
                          ],
                        ),
                      ),

                      //Email
                      GestureDetector(
                        onTap: merchantDetail.data?.merchantEmail == null
                            ? () {
                                dialogInfo(S.of(context).noEmail);
                              }
                            : merchantDetail.data?.merchantEmail == ''
                                ? () {
                                    dialogInfo(S.of(context).noEmail);
                                  }
                                : merchantDetail.data?.merchantEmail != null
                                    ? openEmail
                                    : () {
                                        dialogInfo(S.of(context).noEmail);
                                      },
                        child: Column(
                          children: [
                            _contactCircleIcon(
                              Icons.email_outlined,
                              enabled: merchantDetail.data?.merchantEmail !=
                                      '' &&
                                  merchantDetail.data?.merchantEmail != null,
                              size: 50,
                              iconSize: 27,
                            ),
                            const SizedBox(height: 10),
                            AutoSizeText(S.of(context).emailA,
                                style: dopdownTextStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                //  // Facebook
                //   Row(
                //     children: [
                //       Container(
                //         width: 25,
                //         height: 25,
                //         decoration: const BoxDecoration(
                //             shape: BoxShape.circle, color: GlobalColors.appColor),
                //         child: const Center(
                //           child: FaIcon(FontAwesomeIcons.facebook,
                //               size: 15, color: Colors.white),
                //         ),
                //       ),
                //       const SizedBox(width: 10),
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: merchantDetail.data?.merchantWebsiteInfo == null
                //               ? () {}
                //               : merchantDetail.data?.merchantWebsiteInfo
                //                           ?.facebookLink ==
                //                       ''
                //                   ? () {}
                //                   : merchantDetail.data?.merchantWebsiteInfo
                //                               ?.facebookLink !=
                //                           null
                //                       ? openFacebook
                //                       : () {},
                //           child: AutoSizeText(
                //             merchantDetail.data?.merchantWebsiteInfo == null
                //                 ? S.of(context).noFacebookLink
                //                 : merchantDetail.data!.merchantWebsiteInfo
                //                             ?.facebookLink ==
                //                         ''
                //                     ? S.of(context).noFacebookLink
                //                     : merchantDetail.data!.merchantWebsiteInfo
                //                             ?.facebookLink ??
                //                         S.of(context).noFacebookLink,
                //             style: const TextStyle(
                //               shadows: [
                //                 Shadow(color: Colors.black, offset: Offset(0, -5))
                //               ],
                //               fontSize: 15,
                //               fontWeight: FontWeight.w500,
                //               color: Colors.transparent,
                //               decoration: TextDecoration.underline,
                //               decorationColor: Colors.black,
                //               decorationThickness: 1,
                //               decorationStyle: TextDecorationStyle.solid,
                //               height: 2,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                //   const SizedBox(height: 15),

                //   // Instagram
                //   Row(
                //     children: [
                //       Container(
                //         width: 25,
                //         height: 25,
                //         decoration: const BoxDecoration(
                //             shape: BoxShape.circle, color: GlobalColors.appColor),
                //         child: const Center(
                //           child: FaIcon(FontAwesomeIcons.instagram,
                //               size: 15, color: Colors.white),
                //         ),
                //       ),
                //       const SizedBox(width: 10),
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: merchantDetail.data?.merchantWebsiteInfo == null
                //               ? () {}
                //               : merchantDetail.data?.merchantWebsiteInfo
                //                           ?.instagramLink ==
                //                       ''
                //                   ? () {}
                //                   : merchantDetail.data?.merchantWebsiteInfo
                //                               ?.instagramLink !=
                //                           null
                //                       ? openInstagram
                //                       : () {},
                //           child: AutoSizeText(
                //             merchantDetail.data?.merchantWebsiteInfo == null
                //                 ? S.of(context).noInstagramLink
                //                 : merchantDetail.data!.merchantWebsiteInfo
                //                             ?.instagramLink ==
                //                         ''
                //                     ? S.of(context).noInstagramLink
                //                     : merchantDetail.data!.merchantWebsiteInfo
                //                             ?.instagramLink ??
                //                         S.of(context).noInstagramLink,
                //             style: const TextStyle(
                //               shadows: [
                //                 Shadow(color: Colors.black, offset: Offset(0, -5))
                //               ],
                //               fontSize: 15,
                //               fontWeight: FontWeight.w500,
                //               color: Colors.transparent,
                //               decoration: TextDecoration.underline,
                //               decorationColor: Colors.black,
                //               decorationThickness: 1,
                //               decorationStyle: TextDecorationStyle.solid,
                //               height: 2,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                //   const SizedBox(height: 15),

                //   // Website
                //   Row(
                //     children: [
                //       Container(
                //         width: 25,
                //         height: 25,
                //         decoration: const BoxDecoration(
                //             shape: BoxShape.circle, color: GlobalColors.appColor),
                //         child: const Icon(Icons.language,
                //             size: 15, color: Colors.white),
                //       ),
                //       const SizedBox(width: 10),
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: merchantDetail.data?.merchantWebsiteInfo == null
                //               ? () {}
                //               : merchantDetail.data?.merchantWebsiteInfo
                //                           ?.websiteLink ==
                //                       ''
                //                   ? () {}
                //                   : merchantDetail.data?.merchantWebsiteInfo
                //                               ?.websiteLink !=
                //                           null
                //                       ? openWeb
                //                       : () {},
                //           child: AutoSizeText(
                //             merchantDetail.data?.merchantWebsiteInfo == null
                //                 ? S.of(context).noWebsiteLink
                //                 : merchantDetail.data!.merchantWebsiteInfo
                //                             ?.websiteLink ==
                //                         ''
                //                     ? S.of(context).noWebsiteLink
                //                     : merchantDetail.data!.merchantWebsiteInfo
                //                             ?.websiteLink ??
                //                         S.of(context).noWebsiteLink,
                //             style: const TextStyle(
                //               shadows: [
                //                 Shadow(color: Colors.black, offset: Offset(0, -5))
                //               ],
                //               fontSize: 15,
                //               fontWeight: FontWeight.w500,
                //               color: Colors.transparent,
                //               decoration: TextDecoration.underline,
                //               decorationColor: Colors.black,
                //               decorationThickness: 1,
                //               decorationStyle: TextDecorationStyle.solid,
                //               height: 2,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                //   const SizedBox(height: 15),

                // // Address
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => GoogleMapMerchant(
                //                   latlon: merchantDetail.data!.latlon,
                //                   placeTitle: addressDetail,
                //                 )));
                //   },
                //   child: Row(
                //     mainAxisSize: MainAxisSize.max,
                //     children: [
                //       Container(
                //         width: 25,
                //         height: 25,
                //         decoration: const BoxDecoration(
                //             shape: BoxShape.circle,
                //             color: GlobalColors.appColor),
                //         child: const Icon(Icons.home,
                //             size: 15, color: Colors.white),
                //       ),
                //       const SizedBox(width: 10),
                //       Expanded(
                //         child: AutoSizeText(
                //           // '31 Sportsmans Parade, Bokarina QLD 4575, Nepal
                //           addressDetail!,
                //           style: const TextStyle(
                //             fontSize: 15,
                //             fontWeight: FontWeight.w500,
                //             decoration: TextDecoration.underline,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 75),
      ],
    );
  }

  //Opening Hour pop up
  //Opening Hour pop up
  openingHour(MerchantDetailResModel merchantDetail) {
    String? rawOpeningHours =
        merchantDetail.data?.merchantWebsiteInfo?.openingHourInfo;

    String textToDisplay = (rawOpeningHours == null ||
            rawOpeningHours.trim().isEmpty ||
            rawOpeningHours.trim().toLowerCase() == 'null')
        ? S.of(context).noOpeningHours
        : rawOpeningHours;

    // 1. Parse the string into neat Google-style rows
    List<Widget> hoursListWidgets = [];

    if (textToDisplay == S.of(context).noOpeningHours) {
      hoursListWidgets
          .add(Text(textToDisplay, style: TextStyle(fontSize: 16.sp)));
    } else {
      List<String> lines = textToDisplay.split('\n');
      for (String line in lines) {
        if (line.trim().isEmpty) continue;

        // NEW LOGIC: Find the very first number (digit) in the line
        int firstDigitIndex = line.indexOf(RegExp(r'\d'));

        // If we found a number, split the text there
        if (firstDigitIndex != -1) {
          // Left part gets everything before the number, and we clean up any rogue colons
          String leftPart = line
              .substring(0, firstDigitIndex)
              .replaceAll(RegExp(r'[:-]'), '')
              .trim();
          // Right part gets the number and everything after it
          String rightPart = line.substring(firstDigitIndex).trim();

          if (rightPart.isNotEmpty) {
            hoursListWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        leftPart,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Text(
                        rightPart,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          // If there are NO numbers in the line (e.g., "Sunday Closed" or "Bookings needed")
          hoursListWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                line.trim(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: line.toLowerCase().contains('closed')
                      ? Colors.red.withValues(alpha: 0.8)
                      : Colors.black.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }
      }
    }

    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true,
      barrierColor:
          Colors.black.withValues(alpha: 0.6), // Slightly darker background
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color:
                Colors.transparent, // Required for text styling inside dialogs
            child: Container(
              width: MediaQuery.of(context).size.width / 1.15,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.7, // Keeps it from overflowing
              ),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16.0), // Standard modern rounding
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Hugs content perfectly
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Standard Google Header (Icon + Title)
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled,
                          color: Colors.blueAccent, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        S.of(context).openingHours,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                          color: Colors.black87,
                          fontFamily: 'Sans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 10),

                  // 3. Formatted list of hours
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: hoursListWidgets,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        // Improved Google-like spring transition
        return SlideTransition(
          position: Tween(begin: const Offset(0, 0.1), end: const Offset(0, 0))
              .animate(
                  CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  //iconClick
  dialogInfo(String infoText) {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true, //to dismiss the container once opened
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: InfoPopUp1(
            body: infoText,
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
}

class _BillAmountBottomSheet extends StatefulWidget {
  const _BillAmountBottomSheet({
    required this.currencySymbol,
    this.initialAmount,
  });

  final String currencySymbol;
  final double? initialAmount;

  @override
  State<_BillAmountBottomSheet> createState() => _BillAmountBottomSheetState();
}

class _BillAmountBottomSheetState extends State<_BillAmountBottomSheet> {
  static const Color _primaryBlue = Color(0xFF0009FE);
  static const Color _ctaCyan = Color(0xFF18C6FF);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF63708A);
  static const Color _borderColor = Color(0xFFE2E8F3);

  final TextEditingController _amountController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final double? initialAmount = widget.initialAmount;
    if (initialAmount != null && initialAmount > 0) {
      _amountController.text = initialAmount.toStringAsFixed(2);
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showDiscount() {
    if (_isSubmitting) return;

    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() {
        _errorText = 'Please enter a bill amount greater than 0.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DFEA),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              Text(
                'Enter bill amount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _headingColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Sans',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'TouristSaver will calculate your member discount for this merchant.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _bodyColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Sans',
                  height: 1.35,
                ),
              ),
              SizedBox(height: 18.h),
              TextField(
                controller: _amountController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _showDiscount(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final String value = newValue.text;
                    if (value.isEmpty) return newValue;
                    if ('.'.allMatches(value).length > 1) return oldValue;
                    final int decimalIndex = value.indexOf('.');
                    if (decimalIndex != -1 &&
                        value.substring(decimalIndex + 1).length > 2) {
                      return oldValue;
                    }
                    return newValue;
                  }),
                ],
                style: TextStyle(
                  color: _headingColor,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Sans',
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 8.w),
                    child: Text(
                      '${widget.currencySymbol} ',
                      style: TextStyle(
                        color: _primaryBlue,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ),
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '0.00',
                  errorText: _errorText,
                  filled: true,
                  fillColor: const Color(0xFFF7FAFF),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide:
                        const BorderSide(color: _primaryBlue, width: 1.6),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    borderSide:
                        const BorderSide(color: Colors.redAccent, width: 1.6),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.fromHeight(52.h),
                        side: const BorderSide(color: _borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: _bodyColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Sans',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: _isSubmitting ? null : _showDiscount,
                        child: Ink(
                          height: 52.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primaryBlue, _ctaCyan],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Sans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberDiscountVerificationView extends StatefulWidget {
  const _MemberDiscountVerificationView();

  @override
  State<_MemberDiscountVerificationView> createState() =>
      _MemberDiscountVerificationViewState();
}

class _MemberDiscountVerificationViewState
    extends State<_MemberDiscountVerificationView>
    with SingleTickerProviderStateMixin {
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF63708A);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.98 + (0.02 * value),
            child: child,
          ),
        );
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FBFF),
              Color(0xFFEFF7FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 168.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0A236B).withValues(alpha: 0.10),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/touristsaver-app-logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 34.h),
                  Text(
                    'Applying your member discount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _headingColor,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Sans',
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Calculating the amount you'll pay...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _bodyColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Sans',
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 34.h),
                  _BrandedVerificationSpinner(controller: _controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandedVerificationSpinner extends StatelessWidget {
  const _BrandedVerificationSpinner({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: controller,
      child: Container(
        width: 58.w,
        height: 58.w,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Color(0xFF0009FE),
              Color(0xFF18C6FF),
              Color(0x330009FE),
              Color(0xFF0009FE),
            ],
            stops: [0, 0.45, 0.76, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0009FE).withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
