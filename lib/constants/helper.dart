import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';

import '../common/app_variables.dart';
import '../common/services/device_info.dart';
import '../common/widgets/custom_snackbar.dart';
import '../router.dart';

///URL for Staging and Production
// const baseUrl = 'http://192.168.1.146:3000/api/';
// const baseUrl = 'https://staging.dev.piiink.org/api/';
const baseUrl = 'https://backend.touristsaver.org/api/';

// For user with token or logged in
Future<Dio> getClient() async {
  final Dio dio = Dio();
  String token;
  token = await Pref().readData(key: saveToken);
  String lang = await Pref().readData(key: 'locale') ?? 'en';
  String deviceId = await getDeviceId();
  String myPlatform = Platform.isAndroid
      ? "Android"
      : Platform.isIOS
          ? "iOS"
          : "other";
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
    'accept-language': lang,
    'Device-Info': 'member__${myPlatform}__$deviceId'
  };
  // Map<String, String> qParams = {'lang': lang};
  dio.options
    ..headers = headers
    ..baseUrl = baseUrl
    // ..queryParameters = qParams
    ..connectTimeout = Duration(seconds: 30)
    ..sendTimeout = Duration(seconds: 30)
    ..receiveTimeout = Duration(seconds: 30);
  dio.interceptors
    ..add(LogInterceptor())
    ..add(AuthInterceptor());
  return dio;
}

// For user with no token or not logged in
// For user with no token or not logged in
Future<Dio> getClientNoToken() async {
  final Dio dio = Dio();

  // 1. Safely get Locale
  String lang = 'en';
  try {
    lang = await Pref().readData(key: 'locale') ?? 'en';
  } catch (e) {
    debugPrint("Failed to get locale on iOS: $e");
  }

  // 2. Safely get Device ID
  String deviceId = 'unknown_device';
  try {
    deviceId = await getDeviceId();
  } catch (e) {
    debugPrint("Failed to get device ID on iOS: $e");
  }

  String myPlatform = Platform.isAndroid
      ? "Android"
      : Platform.isIOS
          ? "iOS"
          : "other";

  final headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'accept': 'application/json',
    'accept-language': lang,
    'Device-Info': 'member__${myPlatform}__$deviceId'
  };

  dio.options
    ..headers = headers
    ..baseUrl = baseUrl
    ..connectTimeout = const Duration(seconds: 30)
    ..sendTimeout = const Duration(seconds: 30)
    ..receiveTimeout = const Duration(seconds: 30);

  dio.interceptors.add(LogInterceptor());
  return dio;
}

// Auto Log Out
class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.response?.statusMessage == "Unauthorized") {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (e) {
        debugPrint(e.toString());
      }
      await Pref().removeData(saveToken);
      await Pref().removeData(issuerType);
      // await Pref().removeData(saveCountryID);
      await Pref().removeData('fcmToken');
      await Pref().removeData('isTokenSent');
      await Pref().removeData('notificationsCount');
      await Pref().removeData(saveUserID);
      await Pref().removeData(saveCurrency);
      await Pref().removeData(savePublishableKey);
      await Pref().removeData(userChosenLocationStateID);
      await Pref().removeData(userChosenLocationRegionID);
      AppVariables.accessToken = null;
      AppVariables.notificationLabel.value = 0;
      AppVariables.initNotifications = false;
      GlobalSnackBar.showError(
          navigatorKey.currentContext!, 'Session Expired!');
      navigatorKey.currentContext!
          .pushReplacementNamed('bottom-bar', pathParameters: {'page': '4'});
    }
    super.onError(err, handler);
  }
}
