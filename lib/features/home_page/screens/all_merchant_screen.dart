// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/no_merchant.dart';
import 'package:touristsaver/common/widgets/not_available.dart';
import 'package:touristsaver/common/widgets/small_tab_container.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/home_page/services/home_dio.dart';
import 'package:touristsaver/models/response/merchant_get_all_res.dart';

import '../../../common/app_variables.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../constants/app_image_string.dart';
import '../../../constants/decimal_remove.dart';
import '../../../models/request/mark_fav_req.dart';
import '../../../models/response/common_res.dart';
import '../../../models/response/nearby_res.dart' as near_by_res;
import '../../merchant/services/dio_merchant.dart';
import 'package:touristsaver/generated/l10n.dart';

class AllMerchantScreen extends StatefulWidget {
  static const String routeName = '/all-merchant';
  const AllMerchantScreen({super.key});

  @override
  State<AllMerchantScreen> createState() => _AllMerchantScreenState();
}

class _AllMerchantScreenState extends State<AllMerchantScreen> {
  int allPage = 1;
  bool isFirstLoadingAll = false;
  bool hasNextPageAll = true;
  bool isLoadingMoreAll = false;
  late ScrollController controllerAll;
  List<Datum> merAll = [];
  bool recallMerchantApi = false;
  bool isLoading = false;
  int selectedIndex = 0;
  bool mapViewSelected = false;
  List<Marker> markers = [];
  LatLng? cameraPosition;
  LatLng? edgePosition;
  MarkerId? lastTappedMarkerId;
  GoogleMapController? mapController;
  final GlobalKey _mapKey = GlobalKey();
  Size? _mapSize;
  double zoomLevel = 12;
  double? lastVisibleRadius;
  bool isCameraMoving = false;
  bool zoomedIn = false;
  bool isDataLoading = false;

  //For Error First Load
  String? err;

  //First Load
  void firstLoadAll() async {
    if (!mounted) return;
    setState(() {
      isFirstLoadingAll = true;
    });

    try {
      final resViewAll = await DioHome().getNewMerchant(pageNumber: allPage);
      if (!mounted) return;
      merAll = resViewAll?.data ?? [];
      setState(() {
        isFirstLoadingAll = false;
      });
    } catch (e) {
      err = 'Something went wrong';
      if (!mounted) return;
      setState(() {
        isFirstLoadingAll = false;
      });
    }
  }

  // Fetch data for showing merchant markers on map
  getNearbyMerchants(double radius) async {
    setState(() {
      isDataLoading = true;
    });
    near_by_res.NearByLocationResModel? result =
        await DioMerchant().getNearbyMerchants(
      latitude: cameraPosition?.latitude ?? 0,
      longitude: cameraPosition?.longitude ?? 0,
      radius: radius,
    );
    List<near_by_res.Datum> nearbyMerchants = result?.data ?? [];
    markers.clear();
    for (int i = 0; i < nearbyMerchants.length; i++) {
      near_by_res.Datum merchant = nearbyMerchants[i];
      bool isFavorite = merchant.favoriteMerchant != null ? true : false;
      if (merchant.latitude != null && merchant.longitude != null) {
        markers.add(_marker(merchant, isFavorite));
      }
    }
    setState(() {
      isDataLoading = false;
    });
  }

  // Get total distance between center and edge of the map
  double calculateVisibleDistance(LatLng center, LatLng edge) {
    const double earthRadius = 6371.0; // Radius of the Earth in kilometers

    // Convert coordinates to radians
    final double lat1 = center.latitude * (pi / 180.0);
    final double lon1 = center.longitude * (pi / 180.0);
    final double lat2 = edge.latitude * (pi / 180.0);
    final double lon2 = edge.longitude * (pi / 180.0);

    // Calculate the differences between the coordinates
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    // Apply the Haversine formula
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }

  Marker _marker(near_by_res.Datum? merchant, bool isFavorite) {
    return Marker(
      markerId: MarkerId('${merchant!.id}'),
      position: LatLng(merchant.latitude!, merchant.longitude!),
      infoWindow: InfoWindow(
        title: merchant.merchantName,
        snippet: S.of(context).upToXdiscount.replaceAll(
            '&x',
            removeTrailingZero(
                merchant.maxDiscount?.toStringAsFixed(2) ?? '0')),
        onTap: () {
          onTapped(merchant, isFavorite);
        },
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          (isFavorite) ? BitmapDescriptor.hueRose : BitmapDescriptor.hueAzure),
      consumeTapEvents: true,
      onTap: () {
        lastTappedMarkerId = MarkerId('${merchant.id}');
        mapController!.showMarkerInfoWindow(lastTappedMarkerId!);
      },
    );
  }

  // Fetch visible merchants on map
  getVisibleMerchants() async {
    zoomedIn = false;
    mapController!
        .getLatLng(ScreenCoordinate(x: 0, y: _mapSize!.height.toInt()))
        .then((value) {
      if (!isDataLoading && !isCameraMoving && !zoomedIn) {
        edgePosition = value;
        lastVisibleRadius =
            calculateVisibleDistance(cameraPosition!, edgePosition!);
        getNearbyMerchants(lastVisibleRadius!);
      }
    });
  }

  void onTapped(near_by_res.Datum merchant, bool isFavorite) {
    context.pushNamed('details-screen', extra: {
      'merchantID': merchant.id.toString(),
      // 'isFavorite': isFavorite,
    }).then((value) async {
      if (value == true) {
        if (recallMerchantApi == false) {
          recallMerchantApi = true;
        }
        allPage = 1;
        getVisibleMerchants();
        reloadOk();
      }
    });
  }

  //Load More
  void loadMoreAll() async {
    if (hasNextPageAll == true &&
        isFirstLoadingAll == false &&
        isLoadingMoreAll == false &&
        controllerAll.position.extentAfter < 300) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreAll = true;
      });
      allPage += 1;
      try {
        final res = await DioHome().getNewMerchant(pageNumber: allPage);
        final List<Datum> fetchMerViewAll = res!.data!;
        if (fetchMerViewAll.isNotEmpty) {
          if (!mounted) return;
          merAll.addAll(fetchMerViewAll);
        } else {
          if (!mounted) return;
          setState(() {
            hasNextPageAll = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print(S.of(context).somethingWentWrong);
        }
      }
      if (!mounted) return;
      setState(() {
        isLoadingMoreAll = false;
      });
    }
  }

  // For the refresh Indicator
  final GlobalKey<RefreshIndicatorState> refreshIndicatorProfile =
      GlobalKey<RefreshIndicatorState>();
  reloadOk() async {
    firstLoadAll();
    controllerAll = ScrollController()..addListener(loadMoreAll);
    err = null;
  }

  // Adding to Favourite Merchant
  addToFavorite(Datum merchant) async {
    setState(() {
      isLoading = true;
    });
    var favRes = await DioMerchant().markFavouriteMerchants(
        markFavouriteReqModel: MarkFavouriteReqModel(merchantId: merchant.id));
    if (!mounted) return;
    if (favRes is CommonResModel) {
      if (favRes.status == 'Success') {
        recallMerchantApi = true;
        setState(() {
          merAll
              .firstWhere((e) => e.id == merchant.id, orElse: () => Datum())
              .favoriteMerchant = FavoriteMerchant();
          if (searchResult.isNotEmpty) {
            searchResult
                .firstWhere((e) => e.id == merchant.id, orElse: () => Datum())
                .favoriteMerchant = FavoriteMerchant();
          }
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
  removeFromFavorite(int? merchantId) async {
    setState(() {
      isLoading = true;
    });
    var removeRes =
        await DioMerchant().removeFavouriteMerchants(merchantID: merchantId!);
    if (!mounted) return;
    if (removeRes is SecondCommonResModel) {
      if (removeRes.status == 'Success') {
        recallMerchantApi = true;
        setState(() {
          merAll
              .firstWhere((e) => e.id == merchantId, orElse: () => Datum())
              .favoriteMerchant = null;
          if (searchResult.isNotEmpty) {
            searchResult
                .firstWhere((e) => e.id == merchantId, orElse: () => Datum())
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
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    firstLoadAll();
    controllerAll = ScrollController()..addListener(loadMoreAll);
  }

  //For search
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String searchText = "";
  List<Datum> searchResult = [];
  String? errSearched;

  //For Searched Loading Part
  bool isSearchedChanged = false;

  loadSearchedList() async {
    if (!mounted) return;
    setState(() {
      isSearchedChanged = true;
    });
    try {
      final resSearchedList = await DioHome()
          .getNewMerchant(pageNumber: 1, name: searchController.text.trim());
      if (!mounted) return;
      setState(() {
        searchResult = resSearchedList?.data ?? [];
      });
    } catch (e) {
      if (kDebugMode) {
        errSearched = 'Something went wrong';
      }
    }
    setState(() {
      if (!mounted) return;
      isSearchedChanged = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.pop(recallMerchantApi);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
              text: S.of(context).merchants,
              icon: Icons.arrow_back_ios,
              onPressed: () {
                context.pop(recallMerchantApi);
              }),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                                color: GlobalColors.appColor
                                    .withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                    controller: searchController,
                                    cursorColor: GlobalColors.appColor,
                                    decoration: textInputDecoration.copyWith(
                                        prefixIcon: Icon(
                                          Icons.search,
                                          size: 30.h,
                                          color: GlobalColors.gray,
                                        ),
                                        hintText: S.of(context).search,
                                        hintStyle: const TextStyle(
                                            fontWeight: FontWeight.w400),
                                        suffixIconColor: isSearching
                                            ? GlobalColors.appColor1
                                            : GlobalColors.gray,
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isSearching = false;
                                                isLoading = false;
                                                searchText = "";
                                                searchController.clear();
                                                errSearched = null;
                                                getVisibleMerchants();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                searchResult.clear();
                                                err = null;
                                              });
                                            },
                                            iconSize: 24.h,
                                            icon: const Icon(Icons.clear))),
                                    onTap: () {
                                      setState(() {
                                        isSearching = true;
                                      });
                                    },
                                    onChanged: (value) {
                                      errSearched = null;
                                      searchController.text.length < 3
                                          ? null
                                          : loadSearchedList();
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            if (cameraPosition == null) {
                              if (merAll.isNotEmpty) {
                                double lat = merAll.first.latlon?[0] ??
                                    AppVariables.latitude ??
                                    0.0;
                                double lng = merAll.first.latlon?[1] ??
                                    AppVariables.longitude ??
                                    0.0;
                                cameraPosition = LatLng(lat, lng);
                              } else {
                                cameraPosition = LatLng(
                                    AppVariables.latitude ?? 0.0,
                                    AppVariables.longitude ?? 0.0);
                              }
                            }
                            setState(() {
                              mapViewSelected = !mapViewSelected;
                              mapViewSelected
                                  ? selectedIndex = 1
                                  : selectedIndex = 0;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: mapViewSelected
                                  ? GlobalColors.appColor1
                                      .withValues(alpha: 0.4)
                                  : GlobalColors.appColor1,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: FittedBox(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: mapViewSelected
                                        ? GlobalColors.appColor
                                        : Colors.white,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    S.of(context).mapView,
                                    // 'Map View',
                                    style: mapViewSelected
                                        ? viewAllStyle
                                        : viewAllStyle.copyWith(
                                            color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Merchant List
                searchController.text.isNotEmpty
                    ? Expanded(
                        child: isSearchedChanged == true
                            ? const CustomLoader()
                            : searchedMerchant())
                    : Expanded(
                        child: selectedIndex == 0
                            ? isFirstLoadingAll
                                ? const CustomLoader()
                                : err == 'Something went wrong'
                                    ? const Error1()
                                    : merAll.isEmpty
                                        ? SingleChildScrollView(
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: NotAvailable(
                                                    image:
                                                        "assets/images/no-merchant.png",
                                                    titleText: S
                                                        .of(context)
                                                        .noMerchantAvailable,
                                                    bodyText: S
                                                        .of(context)
                                                        .noMerchantIsAvailableRightNowWeWillKeepYouUpdated),
                                              ),
                                            ),
                                          )
                                        : allMerchant()
                            : Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                        key: _mapKey,
                                        gestureRecognizers: {}
                                          ..add(Factory<
                                                  OneSequenceGestureRecognizer>(
                                              () => EagerGestureRecognizer()))
                                          ..add(Factory<PanGestureRecognizer>(
                                              () => PanGestureRecognizer()))
                                          ..add(Factory<ScaleGestureRecognizer>(
                                              () => ScaleGestureRecognizer()))
                                          ..add(Factory<TapGestureRecognizer>(
                                              () => TapGestureRecognizer()))
                                          ..add(Factory<
                                                  VerticalDragGestureRecognizer>(
                                              () =>
                                                  VerticalDragGestureRecognizer())),
                                        initialCameraPosition: CameraPosition(
                                          target: cameraPosition ??
                                              (markers.isNotEmpty
                                                  ? markers[0].position
                                                  : const LatLng(0, 0)),
                                          zoom: zoomLevel,
                                        ),
                                        onCameraMove: (position) {
                                          if (position.zoom > zoomLevel) {
                                            zoomedIn = true;
                                          } else {
                                            zoomedIn = false;
                                          }
                                          isCameraMoving = true;
                                          cameraPosition = position.target;
                                        },
                                        onCameraIdle: () async {
                                          zoomLevel = await mapController
                                                  ?.getZoomLevel() ??
                                              12;
                                          isCameraMoving = false;
                                          mapController!
                                              .getLatLng(ScreenCoordinate(
                                                  x: 0,
                                                  y: _mapSize!.height.toInt()))
                                              .then((value) {
                                            if (!isDataLoading &&
                                                !isCameraMoving &&
                                                !zoomedIn) {
                                              edgePosition = value;
                                              lastVisibleRadius =
                                                  calculateVisibleDistance(
                                                      cameraPosition!,
                                                      edgePosition!);
                                              getNearbyMerchants(
                                                  lastVisibleRadius!);
                                            }
                                          });
                                        },
                                        markers: markers.toSet(),
                                        onMapCreated: (controller) async {
                                          mapController = controller;
                                          final RenderBox mapRenderBox = _mapKey
                                              .currentContext!
                                              .findRenderObject() as RenderBox;
                                          final double devicePixelRatio =
                                              MediaQuery.of(context)
                                                  .devicePixelRatio;
                                          _mapSize = Size(
                                            mapRenderBox.size.width *
                                                devicePixelRatio,
                                            mapRenderBox.size.height *
                                                devicePixelRatio,
                                          );
                                          if (lastTappedMarkerId != null) {
                                            controller.showMarkerInfoWindow(
                                                lastTappedMarkerId!);
                                          }
                                        }),
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.6),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            IndexWidget(
                                                label: S.of(context).favorite,
                                                color: const Color.fromARGB(
                                                    255, 234, 53, 144)),
                                            SizedBox(height: 5.h),
                                            IndexWidget(
                                                label: S.of(context).regular,
                                                color: const Color.fromARGB(
                                                    255, 53, 144, 234)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isDataLoading)
                                      Positioned(
                                        top: -6,
                                        right: -33,
                                        child: Lottie.asset(
                                          'assets/animations/map_loader.json',
                                          height: 50.sp,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      ),
              ],
            ),
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

  // without searched All Merchant
  allMerchant() {
    return RefreshIndicator(
      key: refreshIndicatorProfile,
      onRefresh: () {
        setState(() {
          allPage = 1;
        });
        return reloadOk();
      },
      color: GlobalColors.appColor,
      child: SingleChildScrollView(
        controller: controllerAll,
        child: Column(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25),
              itemCount: merAll.length,
              itemBuilder: ((context, index) {
                return NewSmallTabContainerWithFav(
                  newSmallOnTap: () {
                    context.pushNamed('details-screen', extra: {
                      'merchantID': merAll[index].id.toString(),
                      // 'isFavorite':
                      // merAll[index].favoriteMerchant != null ? true : false,
                    }).then((value) {
                      if (value == true) {
                        if (recallMerchantApi == false) {
                          recallMerchantApi = true;
                        }
                        allPage = 1;
                        reloadOk();
                      }
                    });
                  },
                  newSmallImage: merAll[index].merchantImageInfo == null
                      ? ''
                      : merAll[index].merchantImageInfo?.logoUrl ??
                          merAll[index].merchantImageInfo?.slider1 ??
                          AppImageString.appNoImageURL,
                  newSmallMerchantName: merAll[index].merchantName!,
                  newSmallDiscountGiven: merAll[index].maxDiscount.toString(),
                  newFavouriteTap: () async {
                    merAll[index].favoriteMerchant == null
                        ? addToFavorite(merAll[index])
                        : removeFromFavorite(merAll[index].id!);
                  },
                  newIsFavouriteTap:
                      merAll[index].favoriteMerchant == null ? false : true,
                );
              }),
            ),
            // checking and loading more
            if (isLoadingMoreAll == true)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: CircularProgressIndicator(
                  color: GlobalColors.loaderColor,
                  strokeWidth: 2.0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  //after searched All Merchant
  searchedMerchant() {
    return SingleChildScrollView(
      padding: searchResult.isEmpty
          ? const EdgeInsets.only(top: 20.0)
          : const EdgeInsets.only(top: 0.0),
      child: searchResult.isEmpty
          ? searchController.text.length < 3
              ? const SizedBox()
              : NoMerchantCard(
                  text: S.of(context).noMerchantFound,
                )
          : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25),
              itemCount: searchResult.length,
              itemBuilder: ((context, index) {
                return NewSmallTabContainerWithFav(
                  newSmallOnTap: () {
                    context.pushNamed('details-screen', extra: {
                      'merchantID': searchResult[index].id.toString(),
                      // 'isFavorite': searchResult[index].favoriteMerchant != null
                      //     ? true
                      //     : false,
                    }).then((value) {
                      if (value == true) {
                        markers.clear();
                        if (recallMerchantApi == false) {
                          recallMerchantApi = true;
                        }
                        allPage = 1;
                        loadSearchedList();
                        reloadOk();
                      }
                    });
                  },
                  newSmallImage: searchResult[index].merchantImageInfo == null
                      ? AppImageString.appNoImageURL
                      : searchResult[index].merchantImageInfo?.logoUrl ??
                          AppImageString.appNoImageURL,
                  newSmallMerchantName: searchResult[index].merchantName!,
                  newSmallDiscountGiven:
                      searchResult[index].maxDiscount.toString(),
                  newFavouriteTap: () async {
                    searchResult[index].favoriteMerchant == null
                        ? addToFavorite(searchResult[index])
                        : removeFromFavorite(searchResult[index].id!);
                  },
                  newIsFavouriteTap:
                      searchResult[index].favoriteMerchant == null
                          ? false
                          : true,
                );
              }),
            ),
    );
  }
}

class IndexWidget extends StatelessWidget {
  const IndexWidget({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.location_on_rounded,
          color: color,
        ),
        SizedBox(width: 5.w),
        AutoSizeText(label, style: viewAllStyle.copyWith(color: color)),
      ],
    );
  }
}
