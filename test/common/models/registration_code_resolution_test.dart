import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/common/models/registration_code_resolution.dart';

void main() {
  group('RegistrationCodeResolution', () {
    test('maps a valid canonical Discovery resolver response', () {
      final resolution = RegistrationCodeResolution.fromJson({
        'valid': true,
        'category': 'campaign_invitation_code',
        'displayName': 'Carrara Markets - July 2026',
        'invitationName': 'Carrara Markets - July 2026',
        'communityGroupName': 'Carrara Markets',
        'campaignName': 'Blue Butterfly Launch Gold Coast',
        'membershipEffect': 'discovery_membership',
      });

      expect(resolution.valid, isTrue);
      expect(resolution.isDiscovery, isTrue);
      expect(resolution.campaignName, 'Blue Butterfly Launch Gold Coast');
      expect(resolution.invitationName, 'Carrara Markets - July 2026');
      expect(resolution.communityGroupName, 'Carrara Markets');
      expect(resolution.membershipEffect, 'discovery_membership');
    });

    test('maps legacy Discovery and Premium categories separately', () {
      final discovery = RegistrationCodeResolution.fromJson({
        'valid': true,
        'category': 'discovery_invitation_code',
      });
      final premium = RegistrationCodeResolution.fromJson({
        'valid': true,
        'category': 'membership_offer_code',
      });

      expect(discovery.isDiscovery, isTrue);
      expect(discovery.isPremium, isFalse);
      expect(premium.isDiscovery, isFalse);
      expect(premium.isPremium, isTrue);
    });

    test('reads Discovery invitation terms from resolver campaign data', () {
      final resolution = RegistrationCodeResolution.fromJson({
        'valid': true,
        'category': 'campaign_invitation_code',
        'campaignMembership': {
          'membershipDays': 45,
          'discoverySavingsCapAmountMinor': 4000,
          'currencyCode': 'AUD',
        },
      });

      expect(resolution.discoveryMembership?.periodDays, 45);
      expect(resolution.discoveryMembership?.effectiveSavingsCapAmount, 40);
      expect(resolution.discoveryMembership?.displayCurrency, r'A$');
    });

    test('does not accept an unknown category as valid', () {
      final resolution = RegistrationCodeResolution.fromJson({
        'valid': true,
        'category': 'unexpected_code_type',
      });

      expect(resolution.valid, isFalse);
      expect(resolution.category, RegistrationCodeCategory.unknown);
    });

    test('distinguishes backend unavailability from an invalid code', () {
      final unavailable = RegistrationCodeResolution.unavailable();
      final invalid = RegistrationCodeResolution.fromJson({
        'valid': false,
        'category': null,
        'reason': 'INVALID_CODE',
      });

      expect(unavailable.backendReached, isFalse);
      expect(
          registrationCodeErrorMessage(unavailable), contains('unavailable'));
      expect(invalid.backendReached, isTrue);
      expect(
        registrationCodeErrorMessage(invalid),
        'We couldn’t verify this code. Please check it and try again.',
      );
    });

    test('uses link-specific wording for a link-originated rejection', () {
      final invalid = RegistrationCodeResolution.fromJson({
        'valid': false,
        'category': null,
        'reason': 'INVALID_CODE',
      });

      expect(
        registrationCodeValidationMessage(
          invalid,
          manuallyEntered: false,
        ),
        unavailableInvitationLinkMessage,
      );
      expect(
        shouldClearPendingInvitationAfterValidationFailure(
          resolution: invalid,
          manuallyEntered: false,
        ),
        isTrue,
      );
    });

    test('keeps manual-code wording for a code the member typed', () {
      final invalid = RegistrationCodeResolution.fromJson({
        'valid': false,
        'category': null,
        'reason': 'INVALID_CODE',
      });

      expect(
        registrationCodeValidationMessage(
          invalid,
          manuallyEntered: true,
        ),
        'We couldn’t verify this code.\nPlease check it and try again.',
      );
      expect(
        shouldClearPendingInvitationAfterValidationFailure(
          resolution: invalid,
          manuallyEntered: true,
        ),
        isFalse,
      );
    });

    test('does not clear link attribution for a backend outage', () {
      final unavailable = RegistrationCodeResolution.unavailable();

      expect(
        registrationCodeValidationMessage(
          unavailable,
          manuallyEntered: false,
        ),
        contains('unavailable'),
      );
      expect(
        shouldClearPendingInvitationAfterValidationFailure(
          resolution: unavailable,
          manuallyEntered: false,
        ),
        isFalse,
      );
    });

    test('maps eligibility reasons to clear member-safe messages', () {
      RegistrationCodeResolution failure(String reason) =>
          RegistrationCodeResolution(
            valid: false,
            category: RegistrationCodeCategory.unknown,
            reason: reason,
          );

      expect(
          registrationCodeErrorMessage(failure('CAMPAIGN_INVITATION_EXPIRED')),
          contains('expired'));
      expect(
        registrationCodeErrorMessage(
          failure('CAMPAIGN_INVITATION_MAX_USES_REACHED'),
        ),
        contains('usage limit'),
      );
      expect(registrationCodeErrorMessage(failure('COUNTRY_NOT_MATCH')),
          contains('membership country'));
      expect(
        registrationCodeErrorMessage(
          failure('REGISTRATION_CODE_ALREADY_REDEEMED'),
        ),
        contains('already been redeemed'),
      );
    });

    test('Apply shows promo-specific eligibility messages from resolver reasons',
        () {
      RegistrationCodeResolution failure(String reason) =>
          RegistrationCodeResolution(
            valid: false,
            category: RegistrationCodeCategory.unknown,
            reason: reason,
          );

      expect(
        registrationPromoCodeApplyErrorMessage(
          failure('CAMPAIGN_INVITATION_EXPIRED'),
        ),
        'This promo code has expired.\nPlease use another code or continue without one.',
      );
      expect(
        registrationPromoCodeApplyErrorMessage(
          failure('MEMBER_PREMIUM_CODE_NOT_VALID'),
        ),
        'This promo code is no longer valid.\nPlease use another code or continue without one.',
      );
      expect(
        registrationPromoCodeApplyErrorMessage(
          failure('MULTI_USE_PREMIUM_CODE_REDEMPTION_LIMIT_REACHED'),
        ),
        'This promo code is no longer available.\nPlease use another code or continue without one.',
      );
      expect(
        registrationPromoCodeApplyErrorMessage(failure('INVALID_CODE')),
        'We couldn’t verify this code.\nPlease check it and try again.',
      );
      expect(
        registrationPromoCodeApplyErrorMessage(
          RegistrationCodeResolution.unavailable(),
        ),
        contains('unavailable'),
      );
    });

    test('requires replacement only for a different pending invitation', () {
      expect(
        registrationCodeReplacementRequired(
          pendingDiscoveryCode: '333BUTTERFLY',
          candidateCode: '333butterfly',
        ),
        isFalse,
      );
      expect(
        registrationCodeReplacementRequired(
          pendingDiscoveryCode: '333BUTTERFLY',
          candidateCode: 'NEW-DISCOVERY',
        ),
        isTrue,
      );
      expect(
        registrationCodeReplacementRequired(
          pendingDiscoveryCode: null,
          candidateCode: 'SAVER20',
        ),
        isFalse,
      );
    });

    test('maps manual Discovery and Premium codes to separate pathways', () {
      const discoveryResolution = RegistrationCodeResolution(
        valid: true,
        category: RegistrationCodeCategory.campaignInvitation,
      );
      const premiumResolution = RegistrationCodeResolution(
        valid: true,
        category: RegistrationCodeCategory.membershipOffer,
      );

      final discovery = RegistrationCodeApplication.fromResolution(
        code: '333BUTTERFLY',
        resolution: discoveryResolution,
      );
      final premium = RegistrationCodeApplication.fromResolution(
        code: 'SAVER20',
        resolution: premiumResolution,
      );

      expect(discovery.registrationCode, '333BUTTERFLY');
      expect(discovery.isDiscovery, isTrue);
      expect(discovery.localPremiumCode, isNull);
      expect(premium.registrationCode, 'SAVER20');
      expect(premium.isDiscovery, isFalse);
      expect(premium.localPremiumCode, 'SAVER20');
    });
  });
}
