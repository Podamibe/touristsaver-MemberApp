import 'package:flutter/material.dart';

import '../l10n/locales.dart';

class AppVariables {
  static String? selectedLanguageNow = 'en';
  static bool initNotifications = false;
  static ValueNotifier<int> notificationLabel = ValueNotifier(0);
  static ValueNotifier<int> payAmountResetSignal = ValueNotifier(0);
  static bool? notificationReceived;
  static String deviceId = '';
  static String? accessToken;
  static String? currency;
  static String? originCountryId;
  static bool? checkIsTerminal;
  static String? userChosenLocationId;
  static String? merchantIssuerID;
  static String? terminalMerchantID;
  static String? terminalName;
  static bool firstBuild = false;
  static bool? showFreePiiinks;
  static Set<String> localeList = {'en'};
  static List<LocaleModel> visibleLocaleList = [];
  // Location Enabled Status
  // 0: Initial status when the app is requesting for location service
  // 1: Status when user declines the acceptance for location service
  // Greater than 1: Status when user grants location service
  static ValueNotifier<int> locationEnabledStatus = ValueNotifier<int>(0);
  static double? latitude;
  static double? longitude;
  static String? countryCode;
  static bool? isLocalAuthEnabled; // For biometric
  static String? checkToken;
  static bool accessConfirmed = false;
  // static int? memRefKPI;
  // static int? piiinkUponMemberReferral;
}
