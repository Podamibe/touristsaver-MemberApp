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
import 'package:touristsaver/common/widgets/no_merchant.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/models/response/merchant_get_all_res.dart';

import '../../../common/app_variables.dart';
import '../../../common/widgets/custom_loader.dart';
import '../../../constants/decimal_remove.dart';
import '../../../constants/global_colors.dart';
import '../../../models/response/nearby_res.dart' as near_by_res;
import '../../merchant/services/dio_merchant.dart';
import '../services/home_dio.dart';
import 'package:touristsaver/generated/l10n.dart';

class MapViewMerchants extends StatefulWidget {
  static const String routeName = '/map-view-merchant';
  const MapViewMerchants({super.key});

  @override
  State<MapViewMerchants> createState() => _MapViewMerchantsState();
}

class _MapViewMerchantsState extends State<MapViewMerchants> {
  int allPage = 1;
  bool isFirstLoadingAll = false;
  List<Datum> merAll = [];
  bool isLoading = false;
  List<Marker> markers = [];
  LatLng? cameraPosition;
  LatLng? edgePosition;
  MarkerId? lastTappedMarkerId;
  GoogleMapController? mapController;
  final GlobalKey _mapKey = GlobalKey();
  Size? _mapSize;
  double zoomLevel = 5;
  double? lastVisibleRadius;
  bool isCameraMoving = false;
  bool zoomedIn = false;
  bool isDataLoading = false;
  bool recallMerchantApi = false;

  // reloadOk() async {
  //   firstLoadAll();
  //   // controllerAll = ScrollController()..addListener(loadMoreAll);
  //   // err = null;
  // }

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
      if (cameraPosition == null) {
        if (merAll.isNotEmpty) {
          double lat = merAll.first.latlon?[0] ?? AppVariables.latitude ?? 0.0;
          double lng = merAll.first.latlon?[1] ?? AppVariables.longitude ?? 0.0;
          cameraPosition = LatLng(lat, lng);
        } else {
          cameraPosition = LatLng(
              AppVariables.latitude ?? 0.0, AppVariables.longitude ?? 0.0);
        }
      }
      setState(() {
        isFirstLoadingAll = false;
      });
    } catch (e) {
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
    }).then((value) async {
      if (value == true) {
        if (recallMerchantApi == false) {
          recallMerchantApi = true;
        }
        allPage = 1;
        getVisibleMerchants();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    firstLoadAll();
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
              text: S.of(context).merchant,
              icon: Icons.arrow_back_ios,
              onPressed: () {
                context.pop(recallMerchantApi);
              }),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            isFirstLoadingAll
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [CustomAllLoader()],
                  )
                : merAll.isEmpty
                    ? Column(
                        children: [
                          NoMerchantCard(
                              text: S.of(context).noMerchantAvailable),
                        ],
                      )
                    : Stack(
                        children: [
                          GoogleMap(
                              key: _mapKey,
                              gestureRecognizers: {}
                                ..add(Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer()))
                                ..add(Factory<PanGestureRecognizer>(
                                    () => PanGestureRecognizer()))
                                ..add(Factory<ScaleGestureRecognizer>(
                                    () => ScaleGestureRecognizer()))
                                ..add(Factory<TapGestureRecognizer>(
                                    () => TapGestureRecognizer()))
                                ..add(Factory<VerticalDragGestureRecognizer>(
                                    () => VerticalDragGestureRecognizer())),
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
                                zoomLevel =
                                    await mapController?.getZoomLevel() ?? 12;
                                isCameraMoving = false;
                                mapController!
                                    .getLatLng(ScreenCoordinate(
                                        x: 0, y: _mapSize!.height.toInt()))
                                    .then((value) {
                                  if (!isDataLoading &&
                                      !isCameraMoving &&
                                      !zoomedIn) {
                                    edgePosition = value;
                                    lastVisibleRadius =
                                        calculateVisibleDistance(
                                            cameraPosition!, edgePosition!);
                                    getNearbyMerchants(lastVisibleRadius!);
                                  }
                                });
                              },
                              markers: markers.toSet(),
                              onMapCreated: (controller) async {
                                mapController = controller;
                                final RenderBox mapRenderBox =
                                    _mapKey.currentContext!.findRenderObject()
                                        as RenderBox;
                                final double devicePixelRatio =
                                    MediaQuery.of(context).devicePixelRatio;
                                _mapSize = Size(
                                  mapRenderBox.size.width * devicePixelRatio,
                                  mapRenderBox.size.height * devicePixelRatio,
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
                                color: Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(15),
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
