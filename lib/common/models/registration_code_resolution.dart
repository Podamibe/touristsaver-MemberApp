import 'package:touristsaver/common/models/discovery_membership_context.dart';
import 'package:touristsaver/common/models/registration_membership_offer.dart';
import 'package:touristsaver/common/models/member_error_presentation.dart';

enum RegistrationCodeCategory {
  campaignInvitation('campaign_invitation_code'),
  discoveryInvitation('discovery_invitation_code'),
  membershipOffer('membership_offer_code'),
  memberInvitation('member_invitation_code'),
  legacyIssuer('legacy_issuer_code'),
  unknown('unknown');

  const RegistrationCodeCategory(this.apiValue);

  final String apiValue;

  static RegistrationCodeCategory fromApiValue(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase();
    return RegistrationCodeCategory.values.firstWhere(
      (category) => category.apiValue == normalized,
      orElse: () => RegistrationCodeCategory.unknown,
    );
  }
}

class RegistrationCodeResolution {
  const RegistrationCodeResolution({
    required this.valid,
    required this.category,
    this.reason,
    this.displayName,
    this.invitationName,
    this.communityGroupName,
    this.campaignName,
    this.membershipEffect,
    this.discoveryMembership,
    this.membershipOffer,
    this.backendReached = true,
  });

  final bool valid;
  final RegistrationCodeCategory category;
  final String? reason;
  final String? displayName;
  final String? invitationName;
  final String? communityGroupName;
  final String? campaignName;
  final String? membershipEffect;
  final DiscoveryMembershipContext? discoveryMembership;
  final RegistrationMembershipOffer? membershipOffer;
  final bool backendReached;

  bool get isDiscovery =>
      category == RegistrationCodeCategory.campaignInvitation ||
      category == RegistrationCodeCategory.discoveryInvitation;

  bool get isPremium => category == RegistrationCodeCategory.membershipOffer;

  factory RegistrationCodeResolution.fromJson(Map<String, dynamic> json) {
    final valid = json['valid'] == true;
    final category = RegistrationCodeCategory.fromApiValue(json['category']);
    final dynamic terms = json['discoveryMembership'] ??
        json['campaignMembership'] ??
        json['membership'];
    return RegistrationCodeResolution(
      valid: valid && category != RegistrationCodeCategory.unknown,
      category: category,
      reason: _string(json['reason']),
      displayName: _string(json['displayName']),
      invitationName: _string(json['invitationName']),
      communityGroupName: _string(json['communityGroupName']),
      campaignName: _string(json['campaignName']),
      membershipEffect: _string(json['membershipEffect']),
      membershipOffer: category == RegistrationCodeCategory.membershipOffer &&
              json['membershipOffer'] is Map
          ? RegistrationMembershipOffer.fromJson(
              Map<String, dynamic>.from(json['membershipOffer'] as Map),
            )
          : null,
      discoveryMembership:
          category == RegistrationCodeCategory.discoveryInvitation ||
                  category == RegistrationCodeCategory.campaignInvitation
              ? DiscoveryMembershipContext.fromJson({
                  ...json,
                  if (terms is Map) ...Map<String, dynamic>.from(terms),
                })
              : null,
    );
  }

  factory RegistrationCodeResolution.unavailable() =>
      const RegistrationCodeResolution(
        valid: false,
        category: RegistrationCodeCategory.unknown,
        reason: 'REGISTRATION_CODE_RESOLVER_UNAVAILABLE',
        backendReached: false,
      );

  static String? _string(dynamic value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result.toLowerCase() == 'null' ? null : result;
  }
}

class RegistrationCodeApplication {
  const RegistrationCodeApplication({
    required this.registrationCode,
    this.localPremiumCode,
    this.memberReferralCode,
    this.issuerCode,
    this.isDiscovery = false,
  });

  final String registrationCode;
  final String? localPremiumCode;
  final String? memberReferralCode;
  final String? issuerCode;
  final bool isDiscovery;

  factory RegistrationCodeApplication.fromResolution({
    required String code,
    required RegistrationCodeResolution resolution,
  }) {
    if (!resolution.valid ||
        resolution.category == RegistrationCodeCategory.unknown) {
      throw ArgumentError('A valid registration-code resolution is required.');
    }
    switch (resolution.category) {
      case RegistrationCodeCategory.campaignInvitation:
      case RegistrationCodeCategory.discoveryInvitation:
        return RegistrationCodeApplication(
          registrationCode: code,
          isDiscovery: true,
        );
      case RegistrationCodeCategory.membershipOffer:
        return RegistrationCodeApplication(
          registrationCode: code,
          localPremiumCode: code,
        );
      case RegistrationCodeCategory.memberInvitation:
        return RegistrationCodeApplication(
          registrationCode: code,
          memberReferralCode: code,
        );
      case RegistrationCodeCategory.legacyIssuer:
        return RegistrationCodeApplication(
          registrationCode: code,
          issuerCode: code,
        );
      case RegistrationCodeCategory.unknown:
        throw StateError('Unknown registration-code category.');
    }
  }
}

String registrationCodeErrorMessage(RegistrationCodeResolution resolution) {
  if (!resolution.backendReached) {
    return 'The invitation service is unavailable. Please check your connection and try again.';
  }
  switch (resolution.reason?.trim().toUpperCase()) {
    case 'CAMPAIGN_INVITATION_EXPIRED':
    case 'CAMPAIGN_INVITATION_CHANNEL_EXPIRED':
    case 'TOKEN_EXPIRED':
    case 'ASSIGNMENT_OUTSIDE_WINDOW':
    case 'CAMPAIGN_OUTSIDE_WINDOW':
    case 'INVITATION_EXPIRED':
      return 'This invitation has expired.';
    case 'CAMPAIGN_INVITATION_INACTIVE':
    case 'CAMPAIGN_INVITATION_CHANNEL_INACTIVE':
    case 'CAMPAIGN_INVITATION_REVOKED':
    case 'CAMPAIGN_INVITATION_CHANNEL_REVOKED':
    case 'CAMPAIGN_ASSIGNMENT_INACTIVE':
    case 'ATTRIBUTION_TOKEN_INACTIVE':
    case 'TOKEN_INACTIVE':
    case 'ASSIGNMENT_INACTIVE':
    case 'INVITATION_INACTIVE':
      return 'This invitation is no longer active.';
    case 'CAMPAIGN_INACTIVE':
    case 'CAMPAIGN_PAUSED':
    case 'INVITATION_CAMPAIGN_INACTIVE':
      return 'This campaign is currently unavailable.';
    case 'CAMPAIGN_INVITATION_MAX_USES_REACHED':
    case 'CAMPAIGN_INVITATION_CHANNEL_MAX_USES_REACHED':
    case 'CAMPAIGN_USAGE_LIMIT_REACHED':
    case 'TOKEN_USE_LIMIT_REACHED':
    case 'INVITATION_USE_LIMIT_REACHED':
      return 'This invitation has reached its usage limit.';
    case 'COUNTRY_NOT_MATCH':
    case 'COUNTRY_INCOMPATIBLE':
    case 'ATTRIBUTION_TOKEN_COUNTRY_MISMATCH':
    case 'CAMPAIGN_COUNTRY_MISMATCH':
    case 'INVITATION_CAMPAIGN_COUNTRY_MISMATCH':
      return 'This invitation is not available for the selected membership country.';
    case 'CAMPAIGN_INVITATION_ALREADY_REDEEMED':
    case 'REGISTRATION_CODE_ALREADY_REDEEMED':
      return 'This invitation has already been redeemed.';
    case 'REGISTRATION_CODE_AMBIGUOUS':
      return 'This code cannot be safely identified. Please contact TouristSaver support.';
    default:
      return 'We couldn’t verify this code. Please check it and try again.';
  }
}

String registrationPromoCodeApplyErrorMessage(
  RegistrationCodeResolution resolution,
) {
  if (!resolution.backendReached) return registrationCodeErrorMessage(resolution);
  return MemberErrorPresenter.present(
    code: resolution.reason,
    context: MemberErrorContext.promoApply,
  ).displayText;
}

const String unavailableInvitationLinkMessage =
    'This invitation link is no longer available. You can still continue without an invitation.';

String registrationCodeValidationMessage(
  RegistrationCodeResolution resolution, {
  required bool manuallyEntered,
}) {
  if (!manuallyEntered && resolution.backendReached) {
    return unavailableInvitationLinkMessage;
  }
  return manuallyEntered
      ? registrationPromoCodeApplyErrorMessage(resolution)
      : registrationCodeErrorMessage(resolution);
}

bool shouldClearPendingInvitationAfterValidationFailure({
  required RegistrationCodeResolution resolution,
  required bool manuallyEntered,
}) =>
    !resolution.valid && resolution.backendReached && !manuallyEntered;

bool registrationCodeReplacementRequired({
  required String? pendingDiscoveryCode,
  required String candidateCode,
}) {
  final pending = pendingDiscoveryCode?.trim();
  if (pending == null || pending.isEmpty) return false;
  return pending.toUpperCase() != candidateCode.trim().toUpperCase();
}
