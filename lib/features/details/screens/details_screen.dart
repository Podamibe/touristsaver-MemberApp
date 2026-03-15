// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  //For title in Google Map
  String? addressDetail;

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
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: CustomAppBar(
                      text: merchantDetail.data!.merchantName!,
                      icon: Icons.arrow_back_ios,
                      onPressed: () {
                        isFavoritez == isFavoritez
                            ? context.pop(true)
                            : context.pop();
                      }),
                ),
                body: IgnorePointer(
                  ignoring: isLoading,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            CarouselWidget(imageList: imageList),
                            const SizedBox(height: 20),
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

    //For Exact Time with device
    DateFormat dateFormat = DateFormat(" HH:mm");
    String dateTime = dateFormat.format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // More Offers
        Center(
          child: Container(
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
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/percentage.png',
                          height: 50.h,
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.contain,
                        ),
                        Column(
                          children: [
                            // Date
                            AutoSizeText(
                              DateFormat('EEEE').format(
                                        DateTime.now(),
                                      ) ==
                                      'Sunday'
                                  ? S.of(context).sunday + dateTime.toString()
                                  : DateFormat('EEEE').format(
                                            DateTime.now(),
                                          ) ==
                                          'Monday'
                                      ? S.of(context).monday +
                                          dateTime.toString()
                                      : DateFormat('EEEE').format(
                                                DateTime.now(),
                                              ) ==
                                              'Tuesday'
                                          ? S.of(context).tuesday +
                                              dateTime.toString()
                                          : DateFormat('EEEE').format(
                                                    DateTime.now(),
                                                  ) ==
                                                  'Wednesday'
                                              ? S.of(context).wednesday +
                                                  dateTime.toString()
                                              : DateFormat('EEEE').format(
                                                        DateTime.now(),
                                                      ) ==
                                                      'Thursday'
                                                  ? S.of(context).thursday +
                                                      dateTime.toString()
                                                  : DateFormat('EEEE').format(
                                                            DateTime.now(),
                                                          ) ==
                                                          'Friday'
                                                      ? S.of(context).friday +
                                                          dateTime.toString()
                                                      : S.of(context).saturday +
                                                          dateTime
                                                              .toString(), //gives 12 hour time format
                              style: transactionTextStyle,
                            ),
                            SizedBox(height: 5.h),
                            // Discount
                            AutoSizeText(
                              '${removeTrailingZero(merchantDetail.data?.discountAtHourOfDay.toString() ?? S.of(context).noDiscount)}%',
                              style: TextStyle(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                        AppVariables.accessToken == null
                            ? Image.asset(
                                'assets/images/percentage.png',
                                height: 50.h,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.contain,
                              )
                            : SizedBox(
                                height: 50.h,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: isLoading
                                      ? const CustomAllLoader1()
                                      : IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            int merchantId =
                                                int.parse(widget.merchantID!);
                                            isFavoritez == true
                                                ? removeFromFavorites(
                                                    merchantId)
                                                : addToFavorites(merchantId);
                                          },
                                          iconSize: 50.h,
                                          padding: EdgeInsets.zero,
                                          icon: Icon(isFavoritez == true
                                              ? Icons.favorite
                                              : Icons.favorite_border),
                                          color: GlobalColors.appColor,
                                        ),
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    if (AppVariables.accessToken != null)
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0)),
                        height: 45.h,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pushNamed('pay',
                                extra: merchantDetail.data?.merchantName);
                          },
                          style: styleMainButton,
                          child: AutoSizeText(
                            S.of(context).pay,
                            style: buttonText,
                          ),
                        ),
                      ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(2, 2))
                                ]),
                            height: 45.h,
                            //  width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pushNamed('more-offers', extra: {
                                  'argImageList': imageList,
                                  'merchantID': widget.merchantID,
                                });
                              },
                              style: styleMainButton.copyWith(
                                side: WidgetStateProperty.all(const BorderSide(
                                    color: GlobalColors.appColor1, width: 2)),
                                backgroundColor: WidgetStateProperty.all(
                                    GlobalColors.appWhiteBackgroundColor),
                              ),
                              child: AutoSizeText(
                                S.of(context).moreOffers,
                                style: buttonText.copyWith(
                                    color: GlobalColors.appColor1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0)),
                            height: 45.h,
                            //  width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                // context.pushNamed('detail-pay',
                                //     pathParameters: {
                                //       'merchantName': merchantDetail
                                //           .data!.merchantName!,
                                //       'transactionCode': merchantDetail
                                //               .data!.transactionCode ??
                                //           'No Transaction Code',
                                // //     });
                                context.pushNamed('merchant-rating',
                                    extra: {'merchantId': widget.merchantID});
                              },
                              style: styleMainButton.copyWith(
                                side: WidgetStateProperty.all(const BorderSide(
                                    color: GlobalColors.appColor1, width: 2)),
                                backgroundColor: WidgetStateProperty.all(
                                    GlobalColors.appWhiteBackgroundColor),
                              ),
                              child: AutoSizeText(
                                S.of(context).reviews,
                                style: buttonText.copyWith(
                                    color: GlobalColors.appColor1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ),

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
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: const Offset(2, 2),
                                )
                              ]),
                          padding: const EdgeInsets.all(20.0),
                          child: merchantDetail.data!.merchantWebsiteInfo!
                                      .merchantDescription!.length <=
                                  200
                              ? Html(
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

                                    const SizedBox(height: 10),

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
                                            style: viewAllStyle,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2.5),
                                            child: Icon(
                                              isExpand == false
                                                  ? Icons.expand_more
                                                  : Icons.expand_less,
                                              color: GlobalColors.appColor,
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
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            4.0), // adjust padding as needed
                        child: Image.asset(
                          'assets/images/clock.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          openingHour(merchantDetail);
                        },
                        child: AutoSizeText(
                          S.of(context).viewOpeningHours,
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
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            4.0), // adjust padding as needed
                        child: Image.asset(
                          'assets/images/redo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            4.0), // adjust padding as needed
                        child: Image.asset(
                          'assets/images/call.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
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
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              4.0), // adjust padding as needed
                          child: Image.asset(
                            'assets/images/gps.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: merchantDetail.data?.merchantWebsiteInfo
                                                ?.facebookLink ==
                                            '' ||
                                        merchantDetail.data?.merchantWebsiteInfo
                                                ?.facebookLink ==
                                            null
                                    ? Color(0xffb0b0b0)
                                    : Colors.white),
                            child: Center(
                              child: merchantDetail.data?.merchantWebsiteInfo
                                              ?.facebookLink ==
                                          '' ||
                                      merchantDetail.data?.merchantWebsiteInfo
                                              ?.facebookLink ==
                                          null
                                  ? FaIcon(FontAwesomeIcons.facebook,
                                      size: 30, color: Colors.white)
                                  : Image.asset(
                                      'assets/images/facebook.png',
                                    ),
                            ),
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: merchantDetail.data?.merchantWebsiteInfo
                                                ?.instagramLink ==
                                            '' ||
                                        merchantDetail.data?.merchantWebsiteInfo
                                                ?.instagramLink ==
                                            null
                                    ? Color(0xffb0b0b0)
                                    : Colors.white),
                            child: Center(
                              child: merchantDetail.data?.merchantWebsiteInfo
                                              ?.instagramLink ==
                                          '' ||
                                      merchantDetail.data?.merchantWebsiteInfo
                                              ?.instagramLink ==
                                          null
                                  ? FaIcon(FontAwesomeIcons.instagram,
                                      size: 30, color: Colors.white)
                                  : Image.asset('assets/images/instagram.png'),
                            ),
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: merchantDetail.data?.merchantWebsiteInfo
                                                ?.websiteLink ==
                                            '' ||
                                        merchantDetail.data?.merchantWebsiteInfo
                                                ?.websiteLink ==
                                            null
                                    ? Color(0xffb0b0b0)
                                    : Colors.white),
                            child: merchantDetail.data?.merchantWebsiteInfo
                                            ?.websiteLink ==
                                        '' ||
                                    merchantDetail.data?.merchantWebsiteInfo
                                            ?.websiteLink ==
                                        null
                                ? Icon(Icons.language,
                                    size: 30, color: Colors.white)
                                : Image.asset('assets/images/world.png'),
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: merchantDetail.data?.merchantEmail ==
                                            '' ||
                                        merchantDetail.data?.merchantEmail ==
                                            null
                                    ? Color(0xffb0b0b0)
                                    : Colors.white),
                            child: merchantDetail.data?.merchantEmail == '' ||
                                    merchantDetail.data?.merchantEmail == null
                                ? const Icon(Icons.email,
                                    size: 30, color: Colors.white)
                                : Image.asset('assets/images/email.png'),
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
  openingHour(MerchantDetailResModel merchantDetail) {
    String? rawOpeningHours =
        merchantDetail.data?.merchantWebsiteInfo?.openingHourInfo;

    // 2. Check for Dart null, empty strings, AND the word 'null'
    String textToDisplay = (rawOpeningHours == null ||
            rawOpeningHours.trim().isEmpty ||
            rawOpeningHours.trim().toLowerCase() == 'null')
        ? S.of(context).noOpeningHours
        : rawOpeningHours;
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Dismissible(
            direction: DismissDirection.vertical,
            onDismissed: (_) => context.pop(),
            key: const Key('key'),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    // Grey Line
                    Container(
                      width: 65,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(50)),
                    ),

                    const SizedBox(height: 20),
                    AutoSizeText(
                      S.of(context).openingHours,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          decoration: TextDecoration.none,
                          color: Colors.black.withValues(alpha: 0.8),
                          fontFamily: 'Sans'),
                    ),
                    const SizedBox(height: 20),

                    // 3. Use the clean variable we created at the top!
                    AutoSizeText(
                      textToDisplay,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          decoration: TextDecoration.none,
                          color: Colors.black.withValues(alpha: 0.8),
                          fontFamily: 'Sans'),
                    ),

                    const SizedBox(height: 45),
                  ],
                ),
              ),
            ),
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
