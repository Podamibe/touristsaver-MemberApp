// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/common/widgets/custom_loader.dart';
import 'package:new_piiink/common/widgets/error.dart';
import 'package:new_piiink/constants/global_colors.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/style.dart';
import 'package:new_piiink/features/connectivity/cubit/internet_cubit.dart';
import 'package:new_piiink/features/home_page/bloc/slider_blocs.dart';
import 'package:new_piiink/features/home_page/bloc/slider_events.dart';
import 'package:new_piiink/features/home_page/bloc/slider_states.dart';
import 'package:new_piiink/models/response/slider_res.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/utils.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../common/widgets/empty_data.dart';
import '../../../common/widgets/reg_log_slider.dart';
import '../../../constants/convert_to_map_of_string.dart';
import '../../../models/response/app_version_log_model.dart';
import '../../../models/response/category_list_res.dart';
import '../../connectivity/screens/connectivity.dart';
import '../../connectivity/screens/connectivity_screen.dart';
import '../bloc/category_blocs.dart';
import '../bloc/category_events.dart';
import '../../../common/services/dio_common.dart';
import '../../../models/response/piiink_info_res.dart';
import 'package:new_piiink/generated/l10n.dart';

import '../bloc/category_states.dart';
import '../widget/best_offer.dart';
import '../widget/nearby_merchants.dart';
import '../widget/popular_merchant.dart';
import '../widget/tab_container.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorHome =
      GlobalKey<RefreshIndicatorState>();

  bool isLoading = false;
  bool? hideNotificationIcon;
  final GlobalKey alertKey = GlobalKey();
  late AppLifecycleState appLifecycleState;
  bool? forceUpdate = false;
  String? versionApp;
  String? storeLink;
  String? featureList;
  String? platformType;
  String? _version;
  String? _build;
  bool _isUpdateDialogShown = false;
  bool _isShowing = false;

  // Banner data variable

  _getAppVersion() async {
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _version = packageInfo.version;
        _build = packageInfo.buildNumber;
      });
    });
  }

  Future<void> fetchBanner() async {
    try {
      var res = await DioCommon().getBanner();
      print("Banner 1111111API Response: $res");
      if (res != null && res['status'] == "Success") {
        setState(() {
          // We grab the inner 'data' object from the API response
          bannerData = res['data'];
        });
      }
    } catch (e) {
      debugPrint("Error processing banner: $e");
    }
  }

  Future<void> getPiiinkInfo() async {
    PiiinkInfoResModel? piiinkInfoResModel = await DioCommon().piiinkInfo();
    if (!mounted) return;
    setState(() {
      hideNotificationIcon =
          piiinkInfoResModel?.data?.hideMerchantPaymentCodeScanOption;
    });
  }

  Future<void> getVersionLog() async {
    AppVersionLogModel? appVersionLogModel =
        await DioCommon().appVersionLog(platformType);
    if (!mounted) return;
    setState(() {
      forceUpdate = appVersionLogModel!.data![0].forceUpdate;
      versionApp = appVersionLogModel.data![0].version;
      storeLink = appVersionLogModel.data![0].storeLink;
      featureList = appVersionLogModel.data![0].featureList;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      await _getAppVersion();
      await getVersionLog();
      _checkForceUpdate();
    }
  }

  void _checkForceUpdate() {
    // if (forceUpdate == true && version!.compareTo(_version.toString()) > 0) {
    if (forceUpdate == true &&
        (Platform.isAndroid
            ? versionApp != '$_version+$_build'
            : versionApp != _version)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isUpdateDialogShown = true;
        if (_isUpdateDialogShown == true && _isShowing == false) {
          if (!mounted) return;
          _showForceUpdateDialog();
        }
      });
    } else {
      _isUpdateDialogShown = false;
      _isShowing = false;
      if (_isShowing == true) {
        Navigator.pop(alertKey.currentContext!);
      }
    }
  }

  Future<void> _showForceUpdateDialog() async {
    // if (forceUpdate == false) {
    //   context.pop();
    //   return; // Dialog is already shown, do nothing
    // }
    _isShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            key: alertKey,
            title: const Text('App Update Required'),
            content: SizedBox(
              height: 320.h,
              width: 300.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your app version ${Platform.isAndroid ? '$_version+$_build' : _version} is outdated. Please update to the latest version $versionApp.',
                  ),
                  const SizedBox(height: 10),
                  featureList == null || featureList == ""
                      ? const SizedBox()
                      : SizedBox(
                          height: 190.h,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Html(data: featureList ?? ''),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 5),
                  CustomButton(
                    onPressed: () {
                      onUpdate(storeLink!);
                      context.pop();
                      _isShowing = false;
                    },
                    text: S.of(context).update,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  onUpdate(String urlz) {
    String prefixedUrl = prefixHttp(urlz);
    Uri webOpen = Uri.parse(prefixedUrl);
    launchUrl(webOpen,
        mode: Platform.isIOS
            ? LaunchMode.externalApplication
            : LaunchMode.externalNonBrowserApplication);
  }

  checkPlatform() async {
    if (Platform.isAndroid) {
      setState(() {
        platformType = "android";
      });
    } else if (Platform.isIOS) {
      setState(() {
        platformType = "ios";
      });
    }
  }

  dynamic bannerData;

  @override
  void initState() {
    super.initState();
    getPiiinkInfo();
    fetchBanner(); // Added banner fetch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context
          .read<CategoryBloc>()
          .add(LoadCategoryEvent(AppVariables.selectedLanguageNow));
      context.read<SliderBloc>().add(LoadSliderEvent());
      // await appRating.rateApp(context);
      await checkPlatform();
      await _getAppVersion();
      await getVersionLog();
      _checkForceUpdate();
      // bool val = await Pref().readBool(key: 'isShownRegLog') ?? false;
      // if (val == false) {
      //   await paySlider();
      // }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    ConnectivityCubit().close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> paySlider() {
    return showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.1,
        ),
        builder: (context) {
          bool isShownRegLog = true;
          Pref().setBool(key: 'isShownRegLog', value: isShownRegLog);
          return RegLogSlider(
            title: S.of(context).membership,
            body: S
                .of(context)
                .toShopAtTouristSaverMerchantsGetGreatDiscountsAndDonatToYourFavouriteCharityRegisterMembershipOrLogin,
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
          );
        });
  }

  Widget experienceBanner() {
    // Logic to handle redirection
    Future<void> _launchBannerUrl() async {
      final String? rawUrl = bannerData?['url'];
      if (rawUrl != null && rawUrl.isNotEmpty) {
        String prefixedUrl = prefixHttp(rawUrl);
        Uri webUri = Uri.parse(prefixedUrl);
        try {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint("Could not launch $prefixedUrl: $e");
        }
      }
    }

    if (bannerData == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(50.r), // More rounded corners like the image
        onTap: _launchBannerUrl,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 15.w),
          decoration: BoxDecoration(
            // ✅ Exact background color from the image (Bright Royal Blue)
            color: const Color(0xFF5271FF),
            borderRadius: BorderRadius.circular(40.r), // Perfectly oval ends
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bannerData?['information'] ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  // ✅ Bold sans-serif font matching the image
                  fontSize: 25.sp,
                  fontWeight:
                      FontWeight.w800, // Extra bold for "Tap for 4000+..."
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4.h), // Tight spacing like the reference
              Text(
                bannerData?['country'] ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  // ✅ Thinner, slightly smaller font for "Australia & New Zealand"
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500, // Medium weight
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final localeData = context.read<LocaleCubit>().state;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 122),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Image or Logo
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Image.asset(
                      "assets/images/tourist.png",
                      width: 100,
                      height: 50,
                    ),
                  ),
                  if (AppVariables.accessToken != null &&
                      hideNotificationIcon == false)
                    InkWell(
                      onTap: () async {
                        // log('home log notification ${AppVariables.notificationLabel.value}');
                        AppVariables.notificationLabel.value = 0;
                        await Pref().writeInt(
                            key: 'notificationsCount',
                            value: AppVariables.notificationLabel.value);
                        if (!mounted) return;
                        context.pushNamed('notification');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: ValueListenableBuilder(
                          valueListenable: AppVariables.notificationLabel,
                          builder: (context, value, child) {
                            return Badge(
                              backgroundColor: GlobalColors.appColor1,
                              smallSize: 10,
                              isLabelVisible: value != 0,
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: GlobalColors.appColor,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  context.pushNamed('search-merchant').then((value) {
                    if (AppVariables.locationEnabledStatus.value > 1 &&
                        value == true) {
                      AppVariables.locationEnabledStatus.value += 1;
                    }
                  });
                },
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: GlobalColors.appColor.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: const Offset(2, 2),
                        )
                      ]),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Image.asset('assets/images/search.png', height: 20),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          S.of(context).searchForMerchantsCategoryLocation,
                          overflow: TextOverflow.ellipsis,
                          style: searchStyle.copyWith(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        key: refreshIndicatorHome,
        color: GlobalColors.appColor,
        onRefresh: () async {
          context.read<SliderBloc>().add(LoadSliderEvent());
          context
              .read<CategoryBloc>()
              .add(LoadCategoryEvent(AppVariables.selectedLanguageNow));
          await fetchBanner();
          if (!mounted) return;
          setState(() {
            if (AppVariables.locationEnabledStatus.value > 1) {
              AppVariables.locationEnabledStatus.value++;
            }
          });
        },
        child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, state) {
            if (state == ConnectivityState.loading) {
              return const NoInternetLoader();
            } else if (state == ConnectivityState.disconnected) {
              return const NoConnectivityScreen();
            } else if (state == ConnectivityState.connected) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5.0),
                    adSlider(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: AutoSizeText(
                        S.of(context).whatAreYouLookingFor,
                        style: topicStyle,
                      ),
                    ),
                    const SizedBox(height: 15),
                    categoryWidget(),
                    const SizedBox(height: 5), // Reduced from 15/20 to 5
                    ValueListenableBuilder(
                      valueListenable: AppVariables.locationEnabledStatus,
                      builder: (context, value, child) {
                        bool isLoading = value == 0;
                        bool isBannerVisible = bannerData != null &&
                            bannerData['isActive'] == true;
                        return Column(
                          children: [
                            if (isBannerVisible) ...[
                              const SizedBox(height: 1),
                              experienceBanner(),
                              const SizedBox(height: 20),
                            ],
                            BestOffer(
                                key: ValueKey(value), isLoading: isLoading),
                            const SizedBox(height: 20),
                            NearbyMerchants(
                                key: ValueKey(value + 1), isLoading: isLoading),
                            const SizedBox(height: 20),
                            PopularMerchant(
                                key: ValueKey(value + 2), isLoading: isLoading),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  categoryWidget() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoadingState) {
          return SizedBox(
            height: 125,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const TabContainer(icon: '', text: '...');
                }),
          );
        } else if (state is CategoryLoadedState) {
          CategoryListResModel categoryList = state.categoryList;
          return SizedBox(
            height: categoryList.data!.data!.isEmpty ? 50 : 105,
            child: categoryList.data!.data!.isEmpty
                ? EmptyData(text: S.of(context).noCategoryFound)
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 20),
                    itemCount: categoryList.data!.data!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          context.pushNamed('category-screen', pathParameters: {
                            'parentId':
                                categoryList.data!.data![index].id.toString(),
                          }).then((value) {
                            if (value == true) {
                              if (AppVariables.locationEnabledStatus.value >
                                  1) {
                                AppVariables.locationEnabledStatus.value += 1;
                              }
                            }
                          });
                        },
                        child: TabContainer(
                          icon: categoryList.data!.data![index].imageName!,
                          text: categoryList.data!.data![index].name!,
                        ),
                      );
                    }),
          );
        } else if (state is CategoryErrorState) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Error(),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  adSlider() {
    return BlocBuilder<SliderBloc, SliderState>(builder: (context, state) {
      if (state is SliderLoadingState) {
        return const SliderLoader();
      } else if (state is SliderLoadedState) {
        SliderResModel sliderList = state.sliderList;
        return sliderList.data!.isEmpty
            ? emptySliderData()
            : CarouselSlider(
                options: CarouselOptions(
                  height: 230.h,
                  autoPlay: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.95,
                ),
                items: sliderList.data!.map<Widget>((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        height: 230.h,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: GlobalColors.appWhiteBackgroundColor,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: kElevationToShadow[2],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (i.hasLink == true) {
                              if (i.externalLink != null) {
                                String prefixedUrl =
                                    prefixHttp(i.externalLink.toString());
                                Uri webOpen = Uri.parse(prefixedUrl);
                                launchUrl(webOpen,
                                    mode: Platform.isIOS
                                        ? LaunchMode.externalApplication
                                        : LaunchMode
                                            .externalNonBrowserApplication);
                              } else if (i.screenValue != null &&
                                  i.internalLink == 'login') {
                                if (AppVariables.accessToken == null) {
                                  GlobalSnackBar.valid(
                                      context, S.of(context).youAreNotLoggedIn);

                                  context.pushNamed('login');
                                  return;
                                } else {
                                  Map<String, dynamic> extras =
                                      jsonDecode(i.screenValue!);
                                  if (extras.keys.first == "extra") {
                                    context.pushNamed('${i.screenName}',
                                        extra: extras.values.first);
                                    return;
                                  } else if (extras.keys.first ==
                                      "pathParameters") {
                                    //converting Map<String,dynamic> to Map<String,String> from convert to map of String from constants folder.
                                    Map<String, String> pathParams =
                                        convertToMapOfStrings(
                                            extras.values.first);

                                    context.pushNamed('${i.screenName}',
                                        pathParameters: pathParams);
                                    return;
                                  }
                                }
                              } else if (i.screenValue != null &&
                                  i.internalLink != 'login') {
                                Map<String, dynamic> extras =
                                    jsonDecode(i.screenValue!);
                                if (extras.keys.first == "extra") {
                                  context.pushNamed('${i.screenName}',
                                      extra: extras.values.first);
                                  return;
                                } else if (extras.keys.first ==
                                    "pathParameters") {
                                  //converting Map<String,dynamic> to Map<String,String> from convert to map of String from constants folder.
                                  Map<String, String> pathParams =
                                      convertToMapOfStrings(
                                          extras.values.first);

                                  context.pushNamed('${i.screenName}',
                                      pathParameters: pathParams);
                                  return;
                                }
                              } else if (i.screenValue == null &&
                                  i.internalLink == 'login') {
                                if (AppVariables.accessToken == null) {
                                  GlobalSnackBar.valid(
                                      context, S.of(context).youAreNotLoggedIn);

                                  context.pushNamed('login');
                                  return;
                                } else {
                                  context.pushNamed('${i.screenName}');
                                  return;
                                }
                              } else {
                                context.pushNamed('${i.screenName}');
                                return;
                              }
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: i.url!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                  child: FittedBox(child: CustomAllLoader1())),
                              errorWidget: (context, url, error) => Center(
                                  child: Image.asset(
                                      'assets/images/no_image.jpg')),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
      } else if (state is SliderErrorState) {
        return const SliderError();
      } else {
        return const SizedBox();
      }
    });
  }

  emptySliderData() {
    return CarouselSlider(
        options: CarouselOptions(
          height: 230,
          autoPlay: true,
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          viewportFraction: 0.95,
        ),
        items: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 230,
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: GlobalColors.appWhiteBackgroundColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: kElevationToShadow[2],
            ),
            child: Center(
                child: AutoSizeText(
              S.of(context).noSliderImageAdded,
              style: locationStyle,
            )),
          ),
        ]);
  }
}
