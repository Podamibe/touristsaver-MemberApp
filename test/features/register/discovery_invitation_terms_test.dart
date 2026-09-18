import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/common/models/registration_code_resolution.dart';
import 'package:touristsaver/features/register/screens/register_screen.dart';

void main() {
  test('Wings campaign resolver terms take precedence over system defaults',
      () {
    final resolution = RegistrationCodeResolution.fromJson({
      'valid': true,
      'category': 'campaign_invitation_code',
      'displayName': 'butterfly walk',
      'campaignName': 'wings test',
      'discoveryPeriodDays': 30,
      'savingsCapAmountMinor': 5000,
      'currency': 'AUD',
    });

    expect(registrationDiscoveryTerms(resolution.discoveryMembership),
        '30 days · A\$50 savings allowance');
    expect(registrationDiscoveryMembershipTitle(resolution.campaignName),
        'Complimentary wings test Membership');
  });

  test('confirmed backend defaults are used only when terms are absent', () {
    expect(
        registrationDiscoveryTerms(null), '30 days · A\$25 savings allowance');
    expect(registrationDiscoveryMembershipTitle(null),
        'Complimentary Wings of Discovery Membership');
    expect(registrationDiscoveryMembershipTitle('  '),
        'Complimentary Wings of Discovery Membership');
  });
}
