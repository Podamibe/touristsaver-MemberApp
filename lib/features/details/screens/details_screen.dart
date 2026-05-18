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
import 'package:new_piiink/common/utils.dart';
import 'package:new_piiink/common/widgets/custom_app_bar.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/custom_snackbar.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/common/widgets/no_merchant.dart';
import 'package:new_piiink/constants/decimal_remove.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/details/bloc/details_blocs.dart';
import 'package:new_piiink/features/details/bloc/details_events.dart';
import 'package:new_piiink/features/details/bloc/details_states.dart';
import 'package:new_piiink/features/details/screens/carousel_widget.dart';
import 'package:new_piiink/features/details/services/dio_detail.dart';
import 'package:new_piiink/features/details/services/fav_or_not.dart';
import 'package:new_piiink/models/response/detail_res.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../common/app_variables.dart';
import '../../../models/request/mark_fav_req.dart';
import '../../../models/response/common_res.dart';
import '../../merchant/services/dio_merchant.dart';
import 'package:new_piiink/generated/l10n.dart';

import '../../profile/widget/info_popup.dart';
import 'google_map.dart';

class DetailsScreen extends StatefulWidget {
  static const String routeName = '/details-screen';
  final String? merchantID;
  // final bool? isFavorite;

  const DetailsScreen({
    super.key,
    this.merchantID,
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
              body: const SingleChildScrollView(
                child: Column(
                  children: [
                    // SizedBox(height: 10),
                    // CarouselWidget(imageList: []),
                    // SizedBox(height: 20),
                    Center(child: CustomAllLoader()),
                  ],
                ),
              ),
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
                    ignoring: isLoading,
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
                              SizedBox(height: 18.h),
                              detailPage(merchantDetail),
                            ],
                          ),
                        ),
                        if (isLoading)
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

//For locating merchant in google map
  onClicked(List<double>? latlang) async {
    double lat = latlang![0];
    double lon = latlang[1];
    String appleUrl =
        'https://maps.apple.com/?saddr=&daddr=$lat,$lon&directionsmode=driving';
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon';

    Uri appleUri = Uri.parse(appleUrl);
    Uri googleUri = Uri.parse(googleUrl);

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
  Widget _memberOfferCard(MerchantDetailResModel merchantDetail) {
    final String discount = removeTrailingZero(
      merchantDetail.data?.discountAtHourOfDay.toString() ??
          S.of(context).noDiscount,
    );

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
                        'Member offer',
                        style: TextStyle(
                          color: _headingColor,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Sans',
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Available for TouristSaver members',
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
                if (AppVariables.accessToken != null)
                  isLoading
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
                            isFavoritez == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          color: _primaryBlue,
                          tooltip: 'Save offer',
                        ),
              ],
            ),
            SizedBox(height: 15.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FF),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _borderColor),
              ),
              child: Text(
                'Up to $discount% off',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Sans',
                ),
              ),
            ),
            if (AppVariables.accessToken != null) ...[
              SizedBox(height: 16.h),
              _primaryGradientButton(
                label: S.of(context).pay,
                onTap: () {
                  context.pushNamed(
                    'pay',
                    extra: merchantDetail.data?.merchantName,
                  );
                },
              ),
            ],
            SizedBox(height: 10.h),
            Row(
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
                        extra: {'merchantId': widget.merchantID},
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryGradientButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Ink(
          height: 50.h,
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
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'Sans',
              ),
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

  detailPage(MerchantDetailResModel merchantDetail) {
    //Getting address
    addressDetail =
        '${merchantDetail.data?.buildingNo ?? ''} ${merchantDetail.data?.streetInfo ?? ''}${merchantDetail.data?.streetInfo == null ? '' : merchantDetail.data?.streetInfo == '' ? '' : ', '}${merchantDetail.data?.city ?? ''}${merchantDetail.data?.city == null ? '' : merchantDetail.data?.city == '' ? '' : ', '}${merchantDetail.data?.state!.stateName!.toLowerCase() == 'unallocated' ? '' : merchantDetail.data?.state!.stateName}${merchantDetail.data?.state!.stateName!.toLowerCase() == 'unallocated' ? '' : ','}${merchantDetail.data?.postalCodeUser ?? ''}${merchantDetail.data?.postalCodeUser == null ? '' : merchantDetail.data?.postalCodeUser == '' ? '' : ', '}${merchantDetail.data?.country!.countryName}';

    //To open the dial pad of the phone
    callNum() async {
      Uri phoneno = Uri.parse(
          'tel:${merchantDetail.data!.merchantPhoneNumber.toString()}');
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _memberOfferCard(merchantDetail),

        SizedBox(height: 20.h),

        // Additional Information
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: AutoSizeText(
            S.of(context).additionalInformation,
            style: topicStyle,
          ),
        ),
        const SizedBox(height: 10),

        Center(
          child: merchantDetail.data?.merchantWebsiteInfo == null
              ? NoMerchantCard(text: S.of(context).noMerchantDescription)
              : merchantDetail.data!.merchantWebsiteInfo?.merchantDescription ==
                      null
                  ? NoMerchantCard(text: S.of(context).noMerchantDescription)
                  : merchantDetail
                              .data!.merchantWebsiteInfo?.merchantDescription ==
                          ''
                      ? NoMerchantCard(
                          text: S.of(context).noMerchantDescription)
                      : Container(
                          width: MediaQuery.of(context).size.width / 1.05,
                          constraints: const BoxConstraints(
                              //To make height expandable according to the text
                              maxHeight: double.infinity),
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
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
                          child: merchantDetail.data!.merchantWebsiteInfo!
                                      .merchantDescription!.length <=
                                  200
                              ? Html(
                                  style: _compactDescriptionHtmlStyle,
                                  data: merchantDetail.data!
                                      .merchantWebsiteInfo!.merchantDescription
                                      .toString(),
                                  onLinkTap: (url, _, __) async {
                                    if (Platform.isIOS) {
                                      await launchUrlString(
                                        url.toString(),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      await launchUrlString(
                                        url.toString(),
                                        mode: LaunchMode
                                            .externalNonBrowserApplication,
                                      );
                                    }
                                  },
                                )
                              : Column(
                                  children: [
                                    // Description Text
                                    Html(
                                      style: _compactDescriptionHtmlStyle,
                                      data: isExpand == false
                                          ? '${merchantDetail.data!.merchantWebsiteInfo!.merchantDescription!.substring(0, 200)}..'
                                          : merchantDetail
                                              .data!
                                              .merchantWebsiteInfo!
                                              .merchantDescription
                                              .toString(),
                                      onLinkTap: (url, _, __) async {
                                        if (Platform.isIOS) {
                                          await launchUrlString(
                                            url.toString(),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } else {
                                          await launchUrlString(
                                            url.toString(),
                                            mode: LaunchMode
                                                .externalNonBrowserApplication,
                                          );
                                        }
                                      },
                                    ),

                                    SizedBox(height: 4.h),

                                    //See More or See Less Text
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpand = !isExpand;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                            padding:
                                                const EdgeInsets.only(top: 2.5),
                                            child: Icon(
                                              isExpand == false
                                                  ? Icons.expand_more
                                                  : Icons.expand_less,
                                              color: _primaryBlue,
                                              size: 20,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
        ),

        const SizedBox(height: 20),

        // Contact
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: AutoSizeText(
            S.of(context).contact,
            style: topicStyle,
          ),
        ),

        const SizedBox(height: 10),

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
                //Opening Hour
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
                                  _buildDynamicHoursHeader(merchantDetail.data
                                      ?.merchantWebsiteInfo?.openingHourInfo),
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
                                  bottom: 10.0), // Indents text to match header
                              child: _buildOpeningHoursList(merchantDetail),
                            )
                          : const SizedBox(width: double.infinity, height: 0),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    _contactCircleIcon(Icons.directions_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          onClicked(merchantDetail.data!.latlon);
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
                              Shadow(color: Colors.black, offset: Offset(0, -5))
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
                const SizedBox(height: 15),

                // // Address
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoogleMapMerchant(
                                  latlon: merchantDetail.data!.latlon,
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
                const SizedBox(height: 25),
                //Facebook
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
                                      dialogInfo(S.of(context).noFacebookLink);
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
                                      dialogInfo(S.of(context).noInstagramLink);
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
                          : merchantDetail
                                      .data?.merchantWebsiteInfo?.websiteLink ==
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
                            enabled: merchantDetail.data?.merchantEmail != '' &&
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
