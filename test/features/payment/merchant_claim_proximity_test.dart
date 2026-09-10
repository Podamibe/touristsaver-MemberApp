import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/features/payment/widgets/merchant_claim_proximity_fallback.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/apply_piiink_by_merchant_req.dart';

void main() {
  group('direct merchant claim coordinates', () {
    test('includes available latitude and longitude', () {
      final json = const ApplyPiiinkByMerchantReqModel(
        merchantId: 42,
        amount: 70,
        lang: 'en',
        latitude: -27.4698,
        longitude: 153.0251,
      ).toJson();

      expect(json['latitude'], -27.4698);
      expect(json['longitude'], 153.0251);
    });

    test('omits coordinates when location is unavailable', () {
      final json = const ApplyPiiinkByMerchantReqModel(
        merchantId: 42,
        amount: 70,
        lang: 'en',
      ).toJson();

      expect(json, isNot(contains('latitude')));
      expect(json, isNot(contains('longitude')));
    });
  });

  group('proximity 409 parsing', () {
    for (final entry in <String, MerchantClaimLocationStatus>{
      'MEMBER_LOCATION_REQUIRED':
          MerchantClaimLocationStatus.memberLocationRequired,
      'MERCHANT_LOCATION_UNAVAILABLE':
          MerchantClaimLocationStatus.merchantLocationUnavailable,
      'OUTSIDE_ALLOWED_RADIUS':
          MerchantClaimLocationStatus.outsideAllowedRadius,
    }.entries) {
      test('recognises ${entry.key}', () {
        final error = ErrorResModel.fromJson(
          {
            'status': 'Fail',
            'code': merchantProximityErrorCode,
            'message': 'Location verification failed.',
            'data': {
              'locationVerification': {
                'status': entry.key,
                'fallbackAction': 'SCAN_MERCHANT_QR',
              },
            },
          },
          httpStatusCode: 409,
        );

        expect(error.httpStatusCode, 409);
        final failure = MerchantClaimProximityFailure.fromResponse(error);
        expect(failure, isNotNull);
        expect(failure!.locationStatus, entry.value);
        expect(failure.fallbackAction, 'SCAN_MERCHANT_QR');
      });
    }

    test('does not intercept an unrelated conflict', () {
      final error = ErrorResModel.fromJson(
        {
          'status': 'Fail',
          'code': 'SOME_OTHER_CONFLICT',
          'data': {
            'locationVerification': {
              'status': 'OUTSIDE_ALLOWED_RADIUS',
            },
          },
        },
        httpStatusCode: 409,
      );

      expect(MerchantClaimProximityFailure.fromResponse(error), isNull);
    });

    test('does not intercept successful verification states', () {
      for (final status in ['VERIFIED', 'NOT_REQUIRED']) {
        final response = ErrorResModel.fromJson({
          'status': 'Success',
          'code': merchantProximityErrorCode,
          'data': {
            'locationVerification': {'status': status},
          },
        });

        expect(MerchantClaimProximityFailure.fromResponse(response), isNull);
      }
    });
  });

  test('QR fallback retains amount and opens the existing scanner', () {
    expect(
      merchantClaimQrRouteExtra(
        merchantName: 'Test Merchant',
        amount: '70.00',
        returnToSearch: true,
      ),
      {
        'merchantName': 'Test Merchant',
        'returnToSearch': true,
        'initialAmount': '70.00',
        'openScannerOnArrival': true,
      },
    );
  });

  testWidgets('shows friendly copy without exposing a radius', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showMerchantClaimProximityFallback(
                context: context,
                merchantName: 'Test Merchant',
              );
            },
            child: const Text('Claim'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Claim'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        "We can't confirm that you're currently at Test Merchant.",
      ),
      findsOneWidget,
    );
    expect(find.textContaining('metres'), findsNothing);
    expect(find.textContaining('radius'), findsNothing);
    expect(find.text('OK — Scan QR Code'), findsOneWidget);

    await tester.tap(find.text('OK — Scan QR Code'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
