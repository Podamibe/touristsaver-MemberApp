import 'dart:convert';
// import 'dart:developer';
// import 'dart:developer';
import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart' hide Location;
import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as lloc;

import '../app_variables.dart';

class ClaimLocation {
  const ClaimLocation({this.latitude, this.longitude});

  final double? latitude;
  final double? longitude;
}

class LocationService {
  static final LocationService _locationService = LocationService._();
  factory LocationService() {
    return _locationService;
  }
  LocationService._();

  /// Gets coordinates for a direct merchant-profile claim without changing
  /// the app's country-detection state or opening device settings.
  ///
  /// An unavailable result is intentionally non-fatal. The claim request is
  /// still sent without coordinates so the backend can preserve the existing
  /// flow when proximity verification is not required.
  Future<ClaimLocation> getCurrentClaimLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const ClaimLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return const ClaimLocation();
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return ClaimLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return const ClaimLocation();
    }
  }

  // Future<String?> getCountryCode(double latitude, double longitude) async {
  //   try {
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude);
  //     String? countryCode = placemarks.first.isoCountryCode;
  //     return countryCode;
  //   } on PlatformException catch (e) {
  //     debugPrint(e.toString());
  //     return '';
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return '';
  //   }
  // }
  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    const String host = 'https://maps.google.com/maps/api/geocode/json';
    const String apiKey = 'AIzaSyDxe8N2uGDP3nhOEDWRKE6Moepnj9HvrLo';
    final Uri url = Uri.parse('$host?key=$apiKey&language=en&latlng=$lat,$lng');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // if (kDebugMode) {
        //   debugPrint('API Response: ${response.body}');
        // }
        // Extract the country short name from the address components
        for (final result in data['results']) {
          for (final component in result['address_components']) {
            if (component['types'].contains('country')) {
              final String? shortName = component['short_name'];
              // if (kDebugMode) {
              //   debugPrint('Country Short Name: $shortName');
              // }
              return shortName;
            }
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              'Failed to fetch data. Status Code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error: $e');
      }
    }
    return null;
  }

  Future<bool> enableLocationAndFetchCountry() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await lloc.Location.instance.requestService();
      if (!serviceEnabled) {
        AppVariables.locationEnabledStatus.value = 1;
        return false;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (Platform.isAndroid) {
        if (AppVariables.accessConfirmed &&
            permission == LocationPermission.deniedForever) {
          Geolocator.openAppSettings();
          AppVariables.locationEnabledStatus.value = 1;
          return false;
        }
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        AppVariables.locationEnabledStatus.value = 1;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppVariables.locationEnabledStatus.value = 1;
      if (AppVariables.accessConfirmed &&
          permission == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          AppVariables.locationEnabledStatus.value = 2;
          return true;
        }
        AppVariables.locationEnabledStatus.value = 1;
        return false;
      }
      AppVariables.locationEnabledStatus.value = 1;
      return false;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
    AppVariables.latitude = position.latitude;
    AppVariables.longitude = position.longitude;
    AppVariables.countryCode =
        await getAddressFromLatLng(position.latitude, position.longitude);
    // await getCountryCode(position.latitude, position.longitude);
    AppVariables.locationEnabledStatus.value = 2;
    return true;
  }
}


  // Future<String?> getAddressFromLatLng(double lat, double lng) async {
  //   String host = 'https://maps.google.com/maps/api/geocode/json';
  //   String apiKey = 'AIzaSyDxe8N2uGDP3nhOEDWRKE6Moepnj9HvrLo';
  //   final url = '$host?key=$apiKey&language=en&latlng=$lat,$lng';
  //   try {
  //     var response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       Map data = jsonDecode(response.body);
  //       log(response.body);
  //       String? shortName =
  //           data["results"][0]["address_components"][4]["short_name"];
  //       log("response ==== $shortName");
  //       for (var result in data["results"]) {
  //         for (var component in result["address_components"]) {
  //           if (component["types"].contains("country")) {
  //             log("Country Short Name: ${component["short_name"]}");
  //             String? shortName = component["short_name"];
  //             return shortName;
  //           }
  //         }
  //       }
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     // log(e.toString());
  //   }
  //   return null;
  // }


///Sandesh ji code
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart' hide Location;
// import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';

// import '../app_variables.dart';

// class LocationService {
//   static final LocationService _locationService = LocationService._();
//   factory LocationService() {
//     return _locationService;
//   }
//   LocationService._();

//   Future<String?> getCountryCode(double latitude, double longitude) async {
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(latitude, longitude);
//     String? countryCode = placemarks.first.isoCountryCode;
//     return countryCode;
//   }

//   Future<bool> enableLocationAndFetchCountry(BuildContext context) async {
//     Location location = Location();
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;
//     LocationData locationData;

//     serviceEnabled = await location.serviceEnabled();
//     log(serviceEnabled.toString());
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         AppVariables.locationEnabledStatus.value = 1;
//         return false;
//       }
//     }
//     permissionGranted = await location.hasPermission();
//     log(permissionGranted.toString());
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       log(permissionGranted.toString());
//       if (permissionGranted == PermissionStatus.deniedForever) {
//         // ignore: use_build_context_synchronously
//         _showSettingsSnackBar(context);
//       }
//       if (permissionGranted 
//       != PermissionStatus.granted ||
//           permissionGranted != PermissionStatus.grantedLimited) {
//         AppVariables.locationEnabledStatus.value = 1;
//         return false;
//       }
//     }
//     // permissionGranted = await location.hasPermission();
//     log(permissionGranted.toString());
//     if (permissionGranted == PermissionStatus.deniedForever) {
//       // ignore: use_build_context_synchronously
//       _showSettingsSnackBar(context);
//       if (permissionGranted != PermissionStatus.granted ||
//           permissionGranted != PermissionStatus.grantedLimited) {
//         AppVariables.locationEnabledStatus.value = 1;
//         return false;
//       }
//     }

//     locationData = await location.getLocation();
//     AppVariables.latitude = locationData.latitude;
//     AppVariables.longitude = locationData.longitude;
//     AppVariables.countryCode = await getCountryCode(
//         locationData.latitude ?? 0.00, locationData.longitude ?? 0.00);
//     AppVariables.locationEnabledStatus.value = 2;
//     return true;
//   }

//   void _showSettingsSnackBar(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text(
//             "Permission is permanently denied. Open settings to enable."),
//         action: SnackBarAction(
//           label: "Settings",
//           onPressed: () {
//             Geolocator.openLocationSettings();
//           },
//         ),
//       ),
//     );
//   }
// }

/////////////////-------------old concept---------------////////////
    // List<Placemark> placemarks = await placemarkFromCoordinates(
    //     position.latitude, position.longitude);
    // String country = placemarks[0].country;
    // print('Country: $country');
// class LocationService {
//   static final LocationService _locationService = LocationService._();

//   factory LocationService() {
//     return _locationService;
//   }

//   LocationService._();

  // Location location = Location();
  // Future<String?> getCountryCode(double latitude, double longitude) async {
  //   List<Placemark> placemarks =
  //       await placemarkFromCoordinates(latitude, longitude);
  //   String? countryCode = placemarks.first.isoCountryCode;
  //   return countryCode;
  // }

  // Future<bool> requestService() async {
  //   bool serviceEnabled = false;
  //   serviceEnabled = await location.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await location.requestService();
  //     if (!serviceEnabled) {
  //       AppVariables.locationEnabledStatus.value = 1;
  //       return false;
  //     }
  //   }

  //   PermissionStatus permissionStatus = await location.hasPermission();
  //   if (permissionStatus == PermissionStatus.denied) {
  //     permissionStatus = await location.requestPermission();
  //     if (permissionStatus != PermissionStatus.granted) {
  //       AppVariables.locationEnabledStatus.value = 1;
  //       return false;
  //     }
  //   }
  //   PermissionStatus permissionStatus = await location.hasPermission();
  //   if (permissionStatus == PermissionStatus.deniedForever) {
  //     GlobalSnackbar.showError(context,"Please allow location permission in appsettings.",onTap:(){
  // handler.openAppSettings();
  // })
  //     if (permissionStatus != PermissionStatus.granted) {
  //       AppVariables.locationEnabledStatus.value = 1;
  //       return false;
  //     }
  //   }

  //   LocationData locationData = await location.getLocation();
  // AppVariables.latitude = locationData.latitude;
  // AppVariables.longitude = locationData.longitude;
  // AppVariables.countryCode = await getCountryCode(
  //     locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
  // AppVariables.locationEnabledStatus.value = 2;
  // return true;
  // }
//}
