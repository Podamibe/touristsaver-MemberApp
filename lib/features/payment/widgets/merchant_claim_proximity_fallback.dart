import 'package:flutter/material.dart';
import 'package:touristsaver/models/error_res.dart';

const String merchantProximityErrorCode = 'MERCHANT_PROXIMITY_NOT_VERIFIED';

enum MerchantClaimLocationStatus {
  memberLocationRequired,
  merchantLocationUnavailable,
  outsideAllowedRadius,
}

class MerchantClaimProximityFailure {
  const MerchantClaimProximityFailure({
    required this.locationStatus,
    this.fallbackAction,
  });

  final MerchantClaimLocationStatus locationStatus;
  final String? fallbackAction;

  static MerchantClaimProximityFailure? fromResponse(dynamic response) {
    if (response is! ErrorResModel ||
        response.code?.trim().toUpperCase() != merchantProximityErrorCode) {
      return null;
    }

    final dynamic responseData = response.data;
    if (responseData is! Map) return null;
    final dynamic verification = responseData['locationVerification'];
    if (verification is! Map) return null;

    final MerchantClaimLocationStatus? status =
        switch (verification['status']?.toString().trim().toUpperCase()) {
      'MEMBER_LOCATION_REQUIRED' =>
        MerchantClaimLocationStatus.memberLocationRequired,
      'MERCHANT_LOCATION_UNAVAILABLE' =>
        MerchantClaimLocationStatus.merchantLocationUnavailable,
      'OUTSIDE_ALLOWED_RADIUS' =>
        MerchantClaimLocationStatus.outsideAllowedRadius,
      _ => null,
    };
    if (status == null) return null;

    return MerchantClaimProximityFailure(
      locationStatus: status,
      fallbackAction: verification['fallbackAction']?.toString(),
    );
  }
}

String merchantClaimProximityMessage(String merchantName) =>
    "We can't confirm that you're currently at $merchantName.\n\n"
    'To claim the discount available today, please go to the payment counter '
    'at $merchantName and scan their TouristSaver QR code.\n\n'
    'This will confirm the current offer before you pay.';

Map<String, dynamic> merchantClaimQrRouteExtra({
  required String merchantName,
  required String amount,
  required bool returnToSearch,
}) =>
    <String, dynamic>{
      'merchantName': merchantName,
      'returnToSearch': returnToSearch,
      'initialAmount': amount,
      'openScannerOnArrival': true,
    };

Future<bool> showMerchantClaimProximityFallback({
  required BuildContext context,
  required String merchantName,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          content: Text(merchantClaimProximityMessage(merchantName)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('OK — Scan QR Code'),
            ),
          ],
        ),
      ) ??
      false;
}
