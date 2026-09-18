import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/common/models/registration_code_resolution.dart';
import 'package:touristsaver/common/models/registration_membership_offer.dart';

void main() {
  RegistrationCodeResolution resolvedOffer({
    required String codeType,
    required double percentage,
    required double payable,
    bool complimentary = false,
    String currency = 'AUD',
  }) =>
      RegistrationCodeResolution.fromJson({
        'valid': true,
        'category': 'membership_offer_code',
        'membershipOffer': {
          'codeType': codeType,
          'complimentary': complimentary,
          'membershipPackageId': 7,
          'discountPercentage': percentage,
          'baseAmount': 99,
          'payableAmount': payable,
          'currency': currency,
        },
      });

  test('free Legacy Premium code describes complimentary membership', () {
    final offer = resolvedOffer(
      codeType: 'legacy_premium_code',
      percentage: 100,
      payable: 0,
      complimentary: true,
    ).membershipOffer;
    expect(offer?.displayLine, 'Complimentary Premium Membership');
  });

  test('paid Legacy code keeps its actual price', () {
    final offer = resolvedOffer(
      codeType: 'legacy_premium_code',
      percentage: 25,
      payable: 74.25,
    ).membershipOffer;
    expect(offer?.displayLine, r'25% discount · Now A$74.25');
  });

  test('Multi-Use 50% code formats the backend payable amount in AUD', () {
    final offer = resolvedOffer(
      codeType: 'multi_use_premium_code',
      percentage: 50,
      payable: 49.5,
    ).membershipOffer;
    expect(offer?.displayLine, r'50% discount · Now A$49.50');
  });

  test('Multi-Use 100% code describes complimentary membership', () {
    final offer = resolvedOffer(
      codeType: 'multi_use_premium_code',
      percentage: 100,
      payable: 0,
      complimentary: true,
    ).membershipOffer;
    expect(offer?.displayLine, 'Complimentary Premium Membership');
  });

  test('zero payable amount uses complimentary wording even without a flag', () {
    final offer = resolvedOffer(
      codeType: 'multi_use_premium_code',
      percentage: 100,
      payable: 0,
    ).membershipOffer;
    expect(offer?.displayLine, 'Complimentary Premium Membership');
  });

  test('percentage rounds to zero decimals and currency follows response', () {
    final offer = resolvedOffer(
      codeType: 'multi_use_premium_code',
      percentage: 25.6,
      payable: 73.66,
      currency: 'USD',
    ).membershipOffer;
    expect(offer?.displayLine, r'26% discount · Now $73.66');
  });

  test('editing a verified code clears its verified offer', () {
    final offer = resolvedOffer(
      codeType: 'multi_use_premium_code',
      percentage: 50,
      payable: 49.5,
    ).membershipOffer;
    final verified =
        RegistrationPromoVerification(verified: true, offer: offer);
    final edited = verified.edited();
    expect(edited.verified, isFalse);
    expect(edited.offer, isNull);
  });
}
