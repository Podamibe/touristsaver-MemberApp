import 'dart:math' as math;

import 'package:new_piiink/models/response/get_nearby_merchants_res_model.dart'
    as nearby_view_all;
import 'package:new_piiink/models/response/merchant_get_all_res.dart'
    as merchant_all;
import 'package:new_piiink/models/response/nearby_res.dart' as nearby;
import 'package:new_piiink/models/response/search_merchant_res.dart' as search;

class MerchantSummary {
  const MerchantSummary({
    required this.merchantId,
    required this.merchantName,
    this.imageUrl,
    this.logoUrl,
    this.maxDiscount,
    this.distanceKm,
    this.isFavourite,
    this.openStatus,
    this.openStatusLabel,
    this.areaLabel,
    this.categoryLabel,
  });

  final int merchantId;
  final String merchantName;
  final String? imageUrl;
  final String? logoUrl;
  final double? maxDiscount;
  final double? distanceKm;
  final bool? isFavourite;
  final String? openStatus;
  final String? openStatusLabel;
  final String? areaLabel;
  final String? categoryLabel;

  MerchantSummary copyWith({
    String? imageUrl,
    String? logoUrl,
    double? maxDiscount,
    double? distanceKm,
    bool? isFavourite,
    String? openStatus,
    String? openStatusLabel,
    String? areaLabel,
    String? categoryLabel,
  }) {
    return MerchantSummary(
      merchantId: merchantId,
      merchantName: merchantName,
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      distanceKm: distanceKm ?? this.distanceKm,
      isFavourite: isFavourite ?? this.isFavourite,
      openStatus: openStatus ?? this.openStatus,
      openStatusLabel: openStatusLabel ?? this.openStatusLabel,
      areaLabel: areaLabel ?? this.areaLabel,
      categoryLabel: categoryLabel ?? this.categoryLabel,
    );
  }
}

class MerchantSummaryAdapters {
  const MerchantSummaryAdapters._();

  static MerchantSummary? fromMerchantGetAll(
    merchant_all.Datum merchant, {
    double? currentLatitude,
    double? currentLongitude,
    String? categoryLabel,
  }) {
    final int? id = merchant.id;
    final String? name = merchant.merchantName;
    if (id == null || name == null || name.isEmpty) return null;

    return MerchantSummary(
      merchantId: id,
      merchantName: name,
      imageUrl: _firstNotEmpty([
        merchant.merchantImageInfo?.logoUrl,
        merchant.merchantImageInfo?.slider1,
      ]),
      logoUrl: merchant.merchantImageInfo?.logoUrl,
      maxDiscount: merchant.maxDiscount,
      distanceKm: distanceFromLatLon(
        merchant.latlon,
        currentLatitude,
        currentLongitude,
      ),
      isFavourite: merchant.favoriteMerchant != null,
      categoryLabel: categoryLabel,
    );
  }

  static MerchantSummary? fromSearchMerchant(
    search.Merchant merchant, {
    double? currentLatitude,
    double? currentLongitude,
  }) {
    final int? id = merchant.id;
    final String? name = merchant.merchantName;
    if (id == null || name == null || name.isEmpty) return null;

    return MerchantSummary(
      merchantId: id,
      merchantName: name,
      imageUrl: _firstNotEmpty([
        merchant.merchantImageInfo?.logoUrl,
        merchant.merchantImageInfo?.slider1,
      ]),
      logoUrl: merchant.merchantImageInfo?.logoUrl,
      maxDiscount: merchant.maxDiscount,
      distanceKm: distanceFromLatLon(
        merchant.latlon,
        currentLatitude,
        currentLongitude,
      ),
      isFavourite: merchant.favoriteMerchant != null,
      areaLabel: _firstNotEmpty([
        merchant.city?.toString(),
        merchant.streetInfo,
      ]),
    );
  }

  static MerchantSummary? fromNearby(nearby.Datum merchant) {
    final int? id = merchant.id;
    final String? name = merchant.merchantName;
    if (id == null || name == null || name.isEmpty) return null;

    return MerchantSummary(
      merchantId: id,
      merchantName: name,
      imageUrl: _firstNotEmpty([
        merchant.merchantImageInfoLogoUrl,
        merchant.merchantImageInfoSlider1,
      ]),
      logoUrl: merchant.merchantImageInfoLogoUrl,
      maxDiscount: merchant.maxDiscount,
      distanceKm: merchant.distance,
      isFavourite: merchant.favoriteMerchant != null,
      areaLabel: _joinLabels([merchant.statename, merchant.countryname]),
    );
  }

  static MerchantSummary? fromNearbyViewAll(
    nearby_view_all.Datum merchant,
  ) {
    final int? id = merchant.id;
    final String? name = merchant.merchantname;
    if (id == null || name == null || name.isEmpty) return null;

    return MerchantSummary(
      merchantId: id,
      merchantName: name,
      imageUrl: _firstNotEmpty([
        merchant.merchantImageInfoLogoUrl,
        merchant.merchantImageInfoSlider1,
      ]),
      logoUrl: merchant.merchantImageInfoLogoUrl,
      maxDiscount: double.tryParse(merchant.maxdiscount ?? ''),
      distanceKm: merchant.distance,
      isFavourite: merchant.favoritemerchant != null,
    );
  }

  static double? distanceFromLatLon(
    List<double>? latlon,
    double? currentLatitude,
    double? currentLongitude,
  ) {
    if (latlon == null || latlon.length < 2) return null;
    final double latitude = latlon[0];
    final double longitude = latlon[1];
    if (currentLatitude == null || currentLongitude == null) return null;
    return distanceBetween(
      currentLatitude,
      currentLongitude,
      latitude,
      longitude,
    );
  }

  static double distanceBetween(
    double fromLatitude,
    double fromLongitude,
    double toLatitude,
    double toLongitude,
  ) {
    const double earthRadiusKm = 6371;
    final double dLat = _degreesToRadians(toLatitude - fromLatitude);
    final double dLon = _degreesToRadians(toLongitude - fromLongitude);
    final double lat1 = _degreesToRadians(fromLatitude);
    final double lat2 = _degreesToRadians(toLatitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  static String? _firstNotEmpty(List<String?> values) {
    for (final String? value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static String? _joinLabels(List<String?> values) {
    final labels = values
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .toList();
    return labels.isEmpty ? null : labels.join(', ');
  }
}
