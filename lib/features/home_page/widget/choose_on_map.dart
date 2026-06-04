// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:flutter_google_maps_webservices/places.dart";
import 'package:lottie/lottie.dart' hide Marker;
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/models/response/merchant_get_all_res.dart';

import '../../../common/widgets/custom_loader.dart';
import '../../../constants/decimal_remove.dart';
import '../../../constants/global_colors.dart';
import '../../../models/response/nearby_res.dart' as near_by_res;
import '../../merchant/services/dio_merchant.dart';
import 'package:touristsaver/generated/l10n.dart';

class ChooseOnMap extends StatefulWidget {
  static const String routeName = '/choose-on-map';
  final String appBarName;
  const ChooseOnMap({super.key, required this.appBarName});

  @override
  State<ChooseOnMap> createState() => _ChooseOnMapState();
}

class _ChooseOnMapState extends State<ChooseOnMap> {
  TextEditingController searchLocationController = TextEditingController();
  final GlobalKey _mapKey = GlobalKey();
  GoogleMapController? mapController;
  int allPage = 1;
  bool isFirstLoadingAll = false;
  List<Datum> merAll = [];
  bool isLoading = false;
  List<Marker> markers = [];
  LatLng? cameraPosition;
  LatLng? edgePosition;
  MarkerId? lastTappedMarkerId;
  Size? mapSize;
  double zoomLevel = 15;
  // double? lastVisibleRadius;
  // bool isCameraMoving = false;
  // bool zoomedIn = false;
  bool isDataLoading = false;
  bool recallMerchantApi = false;
  double radius = 0;
  double? myLocLat;
  double? myLocLong;
  // bool searchTapped = false;
  List _predictions = [];
  String address = "";
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: "AIzaSyDxe8N2uGDP3nhOEDWRKE6Moepnj9HvrLo");
  //APIKEY_MERCHANTS = AIzaSyDxe8N2uGDP3nhOEDWRKE6Moepnj9HvrLo;
  //Member_apikey = AIzaSyAR-TFtHvWQxA6aBOSn2MdzFEqc5WmCsD8;
  // Fetch data for showing merchant markers on map
  getNearbyMerchants(double radius) async {
    setState(() {
      isDataLoading = true;
    });

    near_by_res.NearByLocationResModel? result =
        await DioMerchant().getNearbyMerchants(
      latitude: myLocLat!,
      longitude: myLocLong!,
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

  Marker _marker(near_by_res.Datum? merchant, bool isFavorite) {
    return Marker(
      markerId: MarkerId('${merchant!.id}'),
      position: LatLng(merchant.latitude!, merchant.longitude!),
      infoWindow: InfoWindow(
        title: merchant.merchantName,
        snippet: S.of(context).upToXdiscount.replaceAll(
            '&x', removeTrailingZero(merchant.maxDiscount!.toStringAsFixed(2))),
        //      'Up to ${removeTrailingZero(merchant.maxDiscount?.toStringAsFixed(2) ?? '0')}% Discount',
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

  void onTapped(near_by_res.Datum merchant, bool isFavorite) {
    context.pushNamed('details-screen', extra: {
      'merchantID': merchant.id.toString(),
    }).then((value) async {
      if (value == true) {
        if (recallMerchantApi == false) {
          recallMerchantApi = true;
        }
        allPage = 1;
        getNearbyMerchants(radius);
      }
    });
  }

  Future<void> _autocompletePlace(String input) async {
    if (input.isNotEmpty) {
      PlacesAutocompleteResponse response =
          await _places.autocomplete(input, language: "en");
      if (response.isOkay) {
        setState(() {
          _predictions = response.predictions;
        });
      }
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  void _searchPlace(String placeId) async {
    PlacesDetailsResponse detailsResponse =
        await _places.getDetailsByPlaceId(placeId);
    if (detailsResponse.isOkay) {
      PlaceDetails details = detailsResponse.result;
      setState(() {
        myLocLat = details.geometry!.location.lat;
        myLocLong = details.geometry!.location.lng;
        getNearbyMerchants(radius);
        _moveToLocation(
            details.geometry!.location.lat, details.geometry!.location.lng);
      });
    }
  }

  void _moveToLocation(double lat, double lng) {
    Timer(const Duration(milliseconds: 500), () async {
      mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: zoomLevel),
      ));
    });
  }

  @override
  void initState() {
    widget.appBarName == "Near Me" ? radius = 20 : radius = 1000;
    myLocLat = AppVariables.latitude;
    myLocLong = AppVariables.longitude;
    getNearbyMerchants(radius);
    super.initState();
  }

  @override
  void dispose() {
    searchLocationController.clear();
    mapController?.dispose();
    super.dispose();
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
              text:
                  '${widget.appBarName == 'Near Me' ? S.of(context).nearMe : S.of(context).chooseOnMap} ',
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
                : widget.appBarName == 'Near Me'
                    ? Stack(
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
                                target: LatLng(AppVariables.latitude!,
                                    AppVariables.longitude!),
                                zoom: zoomLevel,
                              ),
                              myLocationEnabled: true,
                              compassEnabled: true,
                              markers: markers.toSet(),
                              onMapCreated: (controller) async {
                                mapController = controller;
                                final RenderBox mapRenderBox =
                                    _mapKey.currentContext!.findRenderObject()
                                        as RenderBox;
                                final double devicePixelRatio =
                                    MediaQuery.of(context).devicePixelRatio;
                                mapSize = Size(
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
                                      // 'Favorite',
                                      color: const Color.fromARGB(
                                          255, 234, 53, 144)),
                                  SizedBox(height: 5.h),
                                  IndexWidget(
                                      label: S.of(context).regular,
                                      // 'Regular',
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
                      )
                    : Stack(
                        children: [
                          GoogleMap(
                              key: _mapKey,
                              //on Tapping on map it takes latlong and show on map
                              onTap: (LatLng argument) {
                                markers.clear();
                                setState(() {
                                  myLocLat = argument.latitude;
                                  myLocLong = argument.longitude;
                                });
                                getNearbyMerchants(radius);
                                mapController?.animateCamera(
                                    CameraUpdate.newLatLng(argument));
                              },
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
                                target: LatLng(myLocLat!, myLocLong!),
                                zoom: zoomLevel,
                              ),
                              myLocationEnabled: true,
                              compassEnabled: true,
                              markers: markers.toSet(),
                              onMapCreated: (controller) async {
                                mapController = controller;
                                final RenderBox mapRenderBox =
                                    _mapKey.currentContext!.findRenderObject()
                                        as RenderBox;
                                final double devicePixelRatio =
                                    MediaQuery.of(context).devicePixelRatio;
                                mapSize = Size(
                                  mapRenderBox.size.width * devicePixelRatio,
                                  mapRenderBox.size.height * devicePixelRatio,
                                );
                                if (lastTappedMarkerId != null) {
                                  controller.showMarkerInfoWindow(
                                      lastTappedMarkerId!);
                                }
                              }),
                          Positioned(
                            top: 70,
                            left: 7,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IndexWidget(
                                      label: S.of(context).favorite,
                                      // 'Favorite',
                                      color: const Color.fromARGB(
                                          255, 234, 53, 144)),
                                  SizedBox(height: 5.h),
                                  IndexWidget(
                                      label: S.of(context).regular,
                                      //'Regular',
                                      color: const Color.fromARGB(
                                          255, 53, 144, 234)),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 55,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: TextFormField(
                                      controller: searchLocationController,
                                      cursorColor: GlobalColors.appColor,
                                      decoration: textInputDecoration1.copyWith(
                                          contentPadding: const EdgeInsets.only(
                                              left: 10.0,
                                              bottom: 8.0,
                                              top: 8.0),
                                          suffixIconColor:
                                              searchLocationController
                                                      .text.isEmpty
                                                  ? GlobalColors.gray
                                                  : GlobalColors.appColor,
                                          suffixIcon: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  searchLocationController
                                                      .clear();
                                                  _predictions.clear();
                                                });
                                              },
                                              child: searchLocationController
                                                      .text.isEmpty
                                                  ? const Icon(
                                                      Icons.search,
                                                      color:
                                                          GlobalColors.appColor,
                                                    )
                                                  : const Icon(Icons.clear)),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          hintText:
                                              S.of(context).searchByLocation
                                          //  'Search location'
                                          ),
                                      onChanged: _autocompletePlace),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                _predictions.isNotEmpty &&
                                        searchLocationController.text
                                            .trim()
                                            .isNotEmpty
                                    ? Container(
                                        height: 300.h,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _predictions.length,
                                          itemBuilder: (context, index) {
                                            final prediction =
                                                _predictions[index];
                                            return ListTile(
                                              title:
                                                  Text(prediction.description),
                                              onTap: () {
                                                _searchPlace(
                                                    prediction.placeId);
                                                searchLocationController.text =
                                                    prediction.description;
                                                setState(() {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                  _predictions = [];
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                          if (isDataLoading)
                            Positioned(
                              top: 40,
                              right: -33,
                              child: Lottie.asset(
                                'assets/animations/map_loader.json',
                                height: 50.sp,
                              ),
                            ),
                        ],
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
