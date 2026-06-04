// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:touristsaver/common/models/merchant_summary.dart';
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
  const MapViewMerchants({
    super.key,
    this.merchants,
    this.title,
  });

  final List<MerchantSummary>? merchants;
  final String? title;

  @override
  State<MapViewMerchants> createState() => _MapViewMerchantsState();
}

class _MapViewMerchantsState extends State<MapViewMerchants> {
  static const Color _regularPinColor = Color(0xFFF146EA);
  static const Color _favouritePinColor = Color(0xFFFF5A3D);
  static const double _regularPinHue = 302.0;
  static const double _favouritePinHue = 10.0;
  static const Color _brandPurple = Color(0xFF6F2DE2);
  static const Color _brandPink = Color(0xFFE83F91);
  static const Color _headingColor = Color(0xFF111C44);
  static const Color _bodyColor = Color(0xFF61708A);

  int allPage = 1;
  bool isFirstLoadingAll = false;
  List<Datum> merAll = [];
  bool isLoading = false;
  List<Marker> markers = [];
  LatLng? cameraPosition;
  LatLng? edgePosition;
  GoogleMapController? mapController;
  final GlobalKey _mapKey = GlobalKey();
  Size? _mapSize;
  double zoomLevel = 5;
  double? lastVisibleRadius;
  bool isCameraMoving = false;
  bool zoomedIn = false;
  bool isDataLoading = false;
  bool recallMerchantApi = false;
  bool _contextualMarkersReady = false;
  bool _favouritePinIconLoading = false;
  bool _favouritePinIconReady = false;
  BitmapDescriptor _favouritePinIcon =
      BitmapDescriptor.defaultMarkerWithHue(_favouritePinHue);
  _MapMerchantInfo? _selectedMerchant;

  bool get _isContextualMap => widget.merchants != null;

  Future<void> _loadFavouritePinIcon(double devicePixelRatio) async {
    if (_favouritePinIconReady || _favouritePinIconLoading) return;
    _favouritePinIconLoading = true;

    final BitmapDescriptor icon =
        await _createFavouritePinIcon(devicePixelRatio);
    if (!mounted) return;

    setState(() {
      _favouritePinIcon = icon;
      _favouritePinIconReady = true;
      _favouritePinIconLoading = false;
      if (_isContextualMap) {
        _contextualMarkersReady = false;
        _prepareContextualMarkers();
      }
    });
  }

  Future<BitmapDescriptor> _createFavouritePinIcon(
    double devicePixelRatio,
  ) async {
    const double logicalWidth = 34;
    const double logicalHeight = 48;
    final int width = (logicalWidth * devicePixelRatio).round();
    final int height = (logicalHeight * devicePixelRatio).round();
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    canvas.scale(devicePixelRatio);

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final Path shadowPath = _favouritePinPath().shift(const Offset(0, 2));
    canvas.drawPath(shadowPath, shadowPaint);

    final Paint pinPaint = Paint()..color = _favouritePinColor;
    canvas.drawPath(_favouritePinPath(), pinPaint);

    final Paint heartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(_heartPath(const Offset(17, 19), 10.5), heartPaint);

    final ui.Image image = await recorder.endRecording().toImage(width, height);
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = data!.buffer.asUint8List();

    return BitmapDescriptor.bytes(
      bytes,
      width: logicalWidth,
      height: logicalHeight,
      imagePixelRatio: devicePixelRatio,
    );
  }

  Path _favouritePinPath() {
    return Path()
      ..moveTo(17, 47)
      ..cubicTo(14.5, 42.5, 4, 30.5, 4, 19.5)
      ..cubicTo(4, 10.5, 9.8, 4, 17, 4)
      ..cubicTo(24.2, 4, 30, 10.5, 30, 19.5)
      ..cubicTo(30, 30.5, 19.5, 42.5, 17, 47)
      ..close();
  }

  Path _heartPath(Offset center, double size) {
    final double x = center.dx;
    final double y = center.dy;
    return Path()
      ..moveTo(x, y + size * 0.55)
      ..cubicTo(
        x - size * 1.05,
        y - size * 0.05,
        x - size * 0.72,
        y - size * 0.95,
        x - size * 0.22,
        y - size * 0.68,
      )
      ..cubicTo(
        x - size * 0.08,
        y - size * 0.6,
        x,
        y - size * 0.45,
        x,
        y - size * 0.35,
      )
      ..cubicTo(
        x,
        y - size * 0.45,
        x + size * 0.08,
        y - size * 0.6,
        x + size * 0.22,
        y - size * 0.68,
      )
      ..cubicTo(
        x + size * 0.72,
        y - size * 0.95,
        x + size * 1.05,
        y - size * 0.05,
        x,
        y + size * 0.55,
      )
      ..close();
  }

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
    _selectedMerchant = null;
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
    final _MapMerchantInfo merchantInfo = _MapMerchantInfo.fromNearby(
      merchant!,
      isFavorite: isFavorite,
    );
    return Marker(
      markerId: MarkerId('${merchant.id}'),
      position: LatLng(merchant.latitude!, merchant.longitude!),
      infoWindow: InfoWindow(
        title: merchant.merchantName,
        snippet: _infoWindowSnippet(merchantInfo),
        onTap: () {
          onTapped(merchant, isFavorite);
        },
      ),
      icon: isFavorite
          ? _favouritePinIcon
          : BitmapDescriptor.defaultMarkerWithHue(_regularPinHue),
      consumeTapEvents: true,
      onTap: () {
        setState(() {
          _selectedMerchant = merchantInfo;
        });
      },
    );
  }

  Marker _summaryMarker(MerchantSummary merchant) {
    final _MapMerchantInfo merchantInfo =
        _MapMerchantInfo.fromSummary(merchant);
    return Marker(
      markerId: MarkerId('${merchant.merchantId}'),
      position: LatLng(merchant.latitude!, merchant.longitude!),
      infoWindow: InfoWindow(
        title: merchant.merchantName,
        snippet: _infoWindowSnippet(merchantInfo),
        onTap: () => onSummaryTapped(merchant),
      ),
      icon: merchantInfo.isFavourite
          ? _favouritePinIcon
          : BitmapDescriptor.defaultMarkerWithHue(_regularPinHue),
      consumeTapEvents: true,
      onTap: () {
        setState(() {
          _selectedMerchant = merchantInfo;
        });
      },
    );
  }

  String _infoWindowSnippet(_MapMerchantInfo merchant) {
    return '${merchant.offerText}\n'
        'Walk: ${merchant.walkingEstimate}  |  '
        'Drive: ${merchant.drivingEstimate}';
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

  void onSummaryTapped(MerchantSummary merchant) {
    context.pushNamed('details-screen', extra: {
      'merchantID': merchant.merchantId.toString(),
    }).then((value) async {
      if (value == true) {
        recallMerchantApi = true;
      }
    });
  }

  void _prepareContextualCamera() {
    final List<MerchantSummary> mappableMerchants =
        widget.merchants?.where((merchant) => merchant.hasLocation).toList() ??
            [];
    if (mappableMerchants.isNotEmpty) {
      final MerchantSummary firstMerchant = mappableMerchants.first;
      cameraPosition =
          LatLng(firstMerchant.latitude!, firstMerchant.longitude!);
      zoomLevel = mappableMerchants.length == 1 ? 14 : 12;
    } else {
      cameraPosition =
          LatLng(AppVariables.latitude ?? 0.0, AppVariables.longitude ?? 0.0);
    }
  }

  void _prepareContextualMarkers() {
    if (_contextualMarkersReady) return;
    markers = widget.merchants
            ?.where((merchant) => merchant.hasLocation)
            .map(_summaryMarker)
            .toList() ??
        [];
    _selectedMerchant = null;
    _contextualMarkersReady = true;
  }

  Future<void> _fitContextualMarkers() async {
    if (!_isContextualMap || markers.length < 2 || mapController == null) {
      return;
    }

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (final Marker marker in markers.skip(1)) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted || mapController == null) return;
    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        52,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (_isContextualMap) {
      _prepareContextualCamera();
    } else {
      firstLoadAll();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavouritePinIcon(MediaQuery.of(context).devicePixelRatio);
    if (_isContextualMap) {
      _prepareContextualMarkers();
    }
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
              text: widget.title ?? S.of(context).merchant,
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
                : (_isContextualMap ? markers.isEmpty : merAll.isEmpty)
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
                              onTap: (_) {
                                setState(() {
                                  _selectedMerchant = null;
                                });
                              },
                              onCameraIdle: () async {
                                if (_isContextualMap) {
                                  isCameraMoving = false;
                                  return;
                                }
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
                                await _fitContextualMarkers();
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
                                      color: _MapViewMerchantsState
                                          ._favouritePinColor),
                                  SizedBox(height: 5.h),
                                  IndexWidget(
                                      label: S.of(context).regular,
                                      color: _MapViewMerchantsState
                                          ._regularPinColor),
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
                          if (_selectedMerchant != null)
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 20,
                              child: _MerchantMapCard(
                                merchant: _selectedMerchant!,
                                onTap: () {
                                  final _MapMerchantInfo merchant =
                                      _selectedMerchant!;
                                  context.pushNamed('details-screen', extra: {
                                    'merchantID': merchant.id.toString(),
                                  }).then((value) async {
                                    if (value == true) {
                                      recallMerchantApi = true;
                                    }
                                  });
                                },
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

class _MapMerchantInfo {
  const _MapMerchantInfo({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isFavourite,
    this.maxDiscount,
    this.distanceKm,
  });

  factory _MapMerchantInfo.fromNearby(
    near_by_res.Datum merchant, {
    required bool isFavorite,
  }) {
    return _MapMerchantInfo(
      id: merchant.id ?? 0,
      name: merchant.merchantName ?? 'Merchant',
      latitude: merchant.latitude ?? 0,
      longitude: merchant.longitude ?? 0,
      maxDiscount: merchant.maxDiscount,
      distanceKm: merchant.distance,
      isFavourite: isFavorite,
    );
  }

  factory _MapMerchantInfo.fromSummary(MerchantSummary merchant) {
    return _MapMerchantInfo(
      id: merchant.merchantId,
      name: merchant.merchantName,
      latitude: merchant.latitude ?? 0,
      longitude: merchant.longitude ?? 0,
      maxDiscount: merchant.maxDiscount,
      distanceKm: merchant.distanceKm,
      isFavourite: merchant.isFavourite == true,
    );
  }

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double? maxDiscount;
  final double? distanceKm;
  final bool isFavourite;

  String get offerText {
    final String discount =
        removeTrailingZero(maxDiscount?.toStringAsFixed(2) ?? '0');
    return 'Up to $discount% off';
  }

  double? get distanceFromUserKm {
    final double? userLatitude = AppVariables.latitude;
    final double? userLongitude = AppVariables.longitude;
    if (userLatitude != null && userLongitude != null) {
      return MerchantSummaryAdapters.distanceBetween(
        userLatitude,
        userLongitude,
        latitude,
        longitude,
      );
    }
    return distanceKm;
  }

  String get walkingEstimate => _travelEstimate(speedKmh: 4.8, mode: 'walk');

  String get drivingEstimate => _travelEstimate(speedKmh: 35, mode: 'drive');

  String _travelEstimate({
    required double speedKmh,
    required String mode,
  }) {
    final double? distance = distanceFromUserKm;
    if (distance == null) return 'Time unavailable';

    final int minutes = max(1, (distance / speedKmh * 60).round());
    final String time = minutes >= 60
        ? '${minutes ~/ 60} hr ${minutes % 60 == 0 ? '' : '${minutes % 60} min'}'
            .trim()
        : '$minutes min';
    return '$time $mode';
  }
}

class _MerchantMapCard extends StatelessWidget {
  const _MerchantMapCard({
    required this.merchant,
    required this.onTap,
  });

  final _MapMerchantInfo merchant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E9F4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          _MapViewMerchantsState._brandPurple,
                          _MapViewMerchantsState._brandPink,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.place_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle15.copyWith(
                            color: _MapViewMerchantsState._headingColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEFF8),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            merchant.offerText,
                            style: searchStyle.copyWith(
                              color: _MapViewMerchantsState._brandPink,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _TravelTimePill(
                      icon: Icons.directions_walk_rounded,
                      label: merchant.walkingEstimate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TravelTimePill(
                      icon: Icons.directions_car_filled_rounded,
                      label: merchant.drivingEstimate,
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

class _TravelTimePill extends StatelessWidget {
  const _TravelTimePill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: _MapViewMerchantsState._brandPurple,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: searchStyle.copyWith(
                color: _MapViewMerchantsState._bodyColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
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
