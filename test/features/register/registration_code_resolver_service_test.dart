import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/common/models/registration_code_resolution.dart';
import 'package:touristsaver/features/register/services/dio_register.dart';

void main() {
  test('posts the canonical code and country to the unified resolver',
      () async {
    late RequestOptions captured;
    final dio = Dio(
      BaseOptions(baseUrl: 'https://staging.example/api/'),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'valid': true,
                'category': 'campaign_invitation_code',
                'campaignName': 'Blue Butterfly Launch Gold Coast',
                'invitationName': 'Carrara Markets - July 2026',
                'communityGroupName': 'Carrara Markets',
                'membershipEffect': 'discovery_membership',
                'discoveryPeriodDays': 30,
                'savingsCapAmountMinor': 5000,
                'currency': 'AUD',
              },
            ),
          );
        },
      ),
    );

    final resolution =
        await DioRegister(registrationCodeClient: dio).resolveRegistrationCode(
      code: '333BUTTERFLY',
      countryId: 3,
    );

    expect(captured.method, 'POST');
    expect(captured.path, '/registration-codes/resolve');
    expect(captured.data, {
      'code': '333BUTTERFLY',
      'countryId': 3,
    });
    expect(resolution.valid, isTrue);
    expect(resolution.category, RegistrationCodeCategory.campaignInvitation);
    expect(resolution.campaignName, 'Blue Butterfly Launch Gold Coast');
    expect(resolution.invitationName, 'Carrara Markets - July 2026');
    expect(resolution.communityGroupName, 'Carrara Markets');
    expect(resolution.discoveryMembership?.periodDays, 30);
    expect(resolution.discoveryMembership?.effectiveSavingsCapAmount, 50);
    expect(resolution.discoveryMembership?.displayCurrency, r'A$');
  });

  test('returns an unavailable result for transport or backend failure',
      () async {
    final dio = Dio(
      BaseOptions(baseUrl: 'https://staging.example/api/'),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      ),
    );

    final resolution =
        await DioRegister(registrationCodeClient: dio).resolveRegistrationCode(
      code: '333BUTTERFLY',
      countryId: 3,
    );

    expect(resolution.valid, isFalse);
    expect(resolution.backendReached, isFalse);
  });

  test('passes the resolved Premium offer through to registration', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://staging.example/api/'));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(
        Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'valid': true,
            'category': 'membership_offer_code',
            'membershipOffer': {
              'codeType': 'multi_use_premium_code',
              'complimentary': false,
              'membershipPackageId': 7,
              'discountPercentage': 50,
              'baseAmount': 99,
              'payableAmount': 49.5,
              'currency': 'AUD',
            },
          },
        ),
      ),
    ));

    final resolution =
        await DioRegister(registrationCodeClient: dio).resolveRegistrationCode(
      code: 'HALFPRICE',
      countryId: 3,
    );

    expect(resolution.valid, isTrue);
    expect(resolution.membershipOffer?.membershipPackageId, 7);
    expect(
        resolution.membershipOffer?.displayLine, r'50% discount · Now A$49.50');
  });

  test('claims canonical Discovery membership with authenticated code only',
      () async {
    late RequestOptions captured;
    final dio = Dio(BaseOptions(baseUrl: 'https://staging.example/api/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 'success',
                'data': {
                  'discoveryMembership': {
                    'active': true,
                    'status': 'active',
                    'entitlementId': 42,
                    'campaignId': 7,
                    'campaignName': 'Wings of Discovery',
                    'currency': 'AUD',
                    'savingsCapAmountMinor': 2500,
                    'savingsConsumedMinor': 0,
                  },
                },
              },
            ),
          );
        },
      ),
    );

    final result = await DioRegister(authenticatedClient: dio)
        .claimDiscoveryRegistrationCode(code: ' wings2026 ');

    expect(captured.path, '/member/discovery/claim-registration-code');
    expect(captured.data, {'code': 'wings2026'});
    expect(result.isSuccess, isTrue);
    expect(result.membership?.entitlementId, 42);
    expect(result.membership?.campaignName, 'Wings of Discovery');
  });
}
