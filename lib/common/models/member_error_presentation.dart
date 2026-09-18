/// Context keys are stable across locales and can later be sent with an API
/// request for centrally managed member-facing wording.
abstract final class MemberErrorContext {
  static const promoApply = 'promo_apply';
  static const invitation = 'invitation';
  static const registration = 'registration';
  static const otpSend = 'otp_send';
  static const otpVerify = 'otp_verify';
  static const discoveryClaim = 'discovery_claim';
  static const checkout = 'checkout';
  static const paymentConfirmation = 'payment_confirmation';
  static const membershipActivation = 'membership_activation';
}

class MemberErrorPresentation {
  const MemberErrorPresentation({
    required this.title,
    required this.message,
    required this.context,
    required this.locale,
    this.technicalCode,
  });

  final String title;
  final String message;
  final String context;
  final String locale;
  final String? technicalCode;

  String get displayText => '$title\n$message';
}

class _Wording {
  const _Wording(this.title, this.message);
  final String title;
  final String message;
}

abstract final class MemberErrorPresenter {
  static const _generic = _Wording(
    'Something went wrong.',
    'Please try again in a moment.',
  );
  static const _promoUnknown = _Wording(
    'We couldn’t verify this code.',
    'Please check it and try again.',
  );
  static const _promoExpired = _Wording(
    'This promo code has expired.',
    'Please use another code or continue without one.',
  );
  static const _promoInactive = _Wording(
    'This promo code is no longer valid.',
    'Please use another code or continue without one.',
  );
  static const _promoExhausted = _Wording(
    'This promo code is no longer available.',
    'Please use another code or continue without one.',
  );
  static const _invitationUnavailable = _Wording(
    'This invitation is no longer available.',
    'You can continue without it or use another invitation.',
  );
  static const _setup = _Wording(
    'We couldn’t complete your membership setup.',
    'Please try again or contact TouristSaver support.',
  );
  static const _otp = _Wording(
    'That verification code didn’t work.',
    'Please check the code or request a new one.',
  );
  static const _existingAccount = _Wording(
    'You already have a TouristSaver account.',
    'Please sign in or continue your existing registration.',
  );
  static const _paymentUnconfirmed = _Wording(
    'We couldn’t confirm your membership payment.',
    'If you were charged, please do not pay again. Contact TouristSaver support.',
  );

  static const _global = <String, _Wording>{
    'MEMBER_PREMIUM_CODE_NOT_VALID': _invitationUnavailable,
    'EMAIL_OR_PHONE_ALREADY_EXIST': _existingAccount,
    'EMAIL_ALREADY_EXIST': _existingAccount,
    'PHONE_ALREADY_EXIST': _existingAccount,
    'OTP_VERIFY_FAILED': _otp,
    'INVALID_OTP': _otp,
    'EMAIL_OTP_NOT_VALID': _otp,
    'OTP_NOT_FOUND': _otp,
    'CODE_NOT_VALID': _setup,
    'ISSUER_COUNTRY_DID_NOT_MATCH': _setup,
    'DEFAULT_MEMBERSHIP_ISSUER_NOT_CONFIGURED': _setup,
    'DEFAULT_MEMBERSHIP_ISSUER_AMBIGUOUS': _setup,
    'DISCOVERY_ASSIGNMENT_ISSUER_INVALID': _setup,
    'DISCOVERY_ASSIGNMENT_ISSUER_NOT_CONFIGURED': _setup,
    'DISCOVERY_ASSIGNMENT_ISSUER_AMBIGUOUS': _setup,
    'REGISTRATION_SOURCE_ISSUER_NOT_CONFIGURED': _setup,
    'REGISTRATION_SOURCE_ISSUER_AMBIGUOUS': _setup,
    'MULTI_USE_PREMIUM_CODE_ISSUER_NOT_CONFIGURED': _setup,
    'PACKAGE_NOT_FOUND': _setup,
    'PREMIUM_MEMBERSHIP_PACKAGE_NOT_ELIGIBLE': _setup,
    'MEMBERSHIP_COUNTRY_NOT_AVAILABLE': _setup,
    'MEMBERSHIP_COUNTRY_NOT_FOUND': _setup,
    'RESIDENCE_COUNTRY_NOT_FOUND': _setup,
    'FAILED_TO_CREATED': _setup,
    'PAYMENT_FAILED': _paymentUnconfirmed,
    'MEMBERSHIP_TRANSACTION_NOT_FOUND': _paymentUnconfirmed,
  };

  static const _byContext = <String, Map<String, _Wording>>{
    MemberErrorContext.promoApply: {
      'INVALID_CODE': _promoUnknown,
      'REGISTRATION_CODE_REQUIRED': _promoUnknown,
      'REGISTRATION_CODE_INVALID': _promoUnknown,
      'MEMBER_PREMIUM_CODE_NOT_VALID': _promoInactive,
      'CAMPAIGN_INVITATION_EXPIRED': _promoExpired,
      'CAMPAIGN_INVITATION_CHANNEL_EXPIRED': _promoExpired,
      'INVITATION_CODE_EXPIRED': _promoExpired,
      'INVITATION_CAMPAIGN_EXPIRED': _promoExpired,
      'INVITATION_EXPIRED': _promoExpired,
      'TOKEN_EXPIRED': _promoExpired,
      'ASSIGNMENT_OUTSIDE_WINDOW': _promoExpired,
      'CAMPAIGN_OUTSIDE_WINDOW': _promoExpired,
      'CAMPAIGN_INVITATION_INACTIVE': _promoInactive,
      'CAMPAIGN_INVITATION_CHANNEL_INACTIVE': _promoInactive,
      'CAMPAIGN_INVITATION_REVOKED': _promoInactive,
      'CAMPAIGN_INVITATION_CHANNEL_REVOKED': _promoInactive,
      'INVITATION_CODE_INACTIVE': _promoInactive,
      'INVITATION_INACTIVE': _promoInactive,
      'INVITATION_CAMPAIGN_INACTIVE': _promoInactive,
      'INVITATION_GROUP_INACTIVE': _promoInactive,
      'CAMPAIGN_INACTIVE': _promoInactive,
      'CAMPAIGN_PAUSED': _promoInactive,
      'CAMPAIGN_ASSIGNMENT_INACTIVE': _promoInactive,
      'ATTRIBUTION_TOKEN_INACTIVE': _promoInactive,
      'TOKEN_INACTIVE': _promoInactive,
      'ASSIGNMENT_INACTIVE': _promoInactive,
      'MULTI_USE_PREMIUM_CODE_REDEMPTION_LIMIT_REACHED': _promoExhausted,
      'CAMPAIGN_INVITATION_MAX_USES_REACHED': _promoExhausted,
      'CAMPAIGN_INVITATION_CHANNEL_MAX_USES_REACHED': _promoExhausted,
      'INVITATION_CODE_MAX_USES_REACHED': _promoExhausted,
      'INVITATION_CAMPAIGN_MAX_REDEMPTIONS_REACHED': _promoExhausted,
      'CAMPAIGN_USAGE_LIMIT_REACHED': _promoExhausted,
      'TOKEN_USE_LIMIT_REACHED': _promoExhausted,
      'INVITATION_USE_LIMIT_REACHED': _promoExhausted,
      'COUNTRY_NOT_MATCH': _Wording(
        'This code isn’t available for your membership country.',
        'Please choose the correct country or use another code.',
      ),
      'REGISTRATION_CODE_AMBIGUOUS': _setup,
    },
    MemberErrorContext.invitation: {
      'INVALID_CODE': _invitationUnavailable,
      'MEMBER_PREMIUM_CODE_NOT_VALID': _invitationUnavailable,
      'CAMPAIGN_INVITATION_EXPIRED': _invitationUnavailable,
      'CAMPAIGN_INVITATION_REVOKED': _invitationUnavailable,
    },
    MemberErrorContext.otpSend: {
      'EMAIL_OR_PHONE_ALREADY_EXIST': _existingAccount,
      'REFERRAL_CODE_DOES_NOT_EXIST': _Wording(
        'We couldn’t verify the referral code.',
        'Please check it and try again.',
      ),
    },
    MemberErrorContext.registration: {
      'CONFIRM_PASSWORD_DID_NOT_MATCH': _Wording(
        'Your passwords don’t match.',
        'Please check both password fields and try again.',
      ),
      'RESIDENTIAL_POSTAL_CODE_REQUIRED': _Wording(
        'Your postal code is required.',
        'Please enter it and try again.',
      ),
      'RESIDENTIAL_POSTAL_CODE_INVALID': _Wording(
        'That postal code doesn’t look right.',
        'Please check it and try again.',
      ),
      'RESIDENTIAL_POSTAL_CODE_TOO_LONG': _Wording(
        'That postal code is too long.',
        'Please check it and try again.',
      ),
      'REGISTRATION_CODE_CONFLICT': _Wording(
        'These invitations can’t be used together.',
        'Please continue with one invitation.',
      ),
      'MULTI_USE_PREMIUM_CODE_REDEMPTION_LIMIT_REACHED': _promoExhausted,
      'MULTI_USE_PREMIUM_CODE_ALREADY_REDEEMED': _invitationUnavailable,
    },
    MemberErrorContext.discoveryClaim: {
      'DISCOVERY_REQUIRES_FREE_MEMBER': _Wording(
        'This invitation is for Free members.',
        'Please contact TouristSaver support if you need help.',
      ),
      'DISCOVERY_ENTITLEMENT_ALREADY_EXISTS': _Wording(
        'A Discovery membership is already linked to your account.',
        'Please sign in to continue.',
      ),
      'DISCOVERY_ENTITLEMENT_ALREADY_ENDED': _Wording(
        'This invitation has already been used.',
        'Please contact TouristSaver support if you need help.',
      ),
      'PREMIUM_PURCHASE_IN_PROGRESS_OR_COMPLETED': _Wording(
        'A Premium purchase is already in progress.',
        'Please complete it or wait for it to expire before using this invitation.',
      ),
    },
    MemberErrorContext.paymentConfirmation: {
      'PAYMENT_FAILED': _paymentUnconfirmed,
    },
  };

  static MemberErrorPresentation present({
    String? code,
    required String context,
    String locale = 'en',
    String? approvedTitle,
    String? approvedMessage,
  }) {
    final normalizedCode = code?.trim().toUpperCase();
    final hasApprovedText = approvedTitle?.trim().isNotEmpty == true &&
        approvedMessage?.trim().isNotEmpty == true;
    final wording = hasApprovedText
        ? _Wording(approvedTitle!.trim(), approvedMessage!.trim())
        : _byContext[context]?[normalizedCode] ??
            _global[normalizedCode] ??
            _fallbackFor(context);
    return MemberErrorPresentation(
      title: wording.title,
      message: wording.message,
      technicalCode: normalizedCode,
      context: context,
      locale: locale,
    );
  }

  static _Wording _fallbackFor(String context) => switch (context) {
        MemberErrorContext.promoApply => _promoUnknown,
        MemberErrorContext.invitation => _invitationUnavailable,
        MemberErrorContext.paymentConfirmation => _paymentUnconfirmed,
        MemberErrorContext.membershipActivation => _setup,
        _ => _generic,
      };

  /// Older backend responses sometimes put an untranslated code in `message`.
  /// This accepts only code-shaped values; ordinary English text is never used
  /// as a mapping key or shown to a member.
  static String? technicalCodeFromResponse({
    String? code,
    String? reason,
    String? message,
  }) {
    for (final candidate in [code, reason, message]) {
      final value = candidate?.trim();
      if (value != null && RegExp(r'^[A-Z][A-Z0-9_]*$').hasMatch(value)) {
        return value;
      }
    }
    return null;
  }
}
