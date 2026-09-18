import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/common/models/member_error_presentation.dart';
import 'package:touristsaver/models/error_res.dart';

void main() {
  test('known registration, OTP, promo and payment codes use member wording',
      () {
    final promo = MemberErrorPresenter.present(
      code: 'MULTI_USE_PREMIUM_CODE_REDEMPTION_LIMIT_REACHED',
      context: MemberErrorContext.promoApply,
    );
    expect(promo.title, 'This promo code is no longer available.');
    expect(
        promo.technicalCode, 'MULTI_USE_PREMIUM_CODE_REDEMPTION_LIMIT_REACHED');

    final otp = MemberErrorPresenter.present(
      code: 'OTP_VERIFY_FAILED',
      context: MemberErrorContext.registration,
    );
    expect(otp.title, 'That verification code didn’t work.');

    final account = MemberErrorPresenter.present(
      code: 'EMAIL_OR_PHONE_ALREADY_EXIST',
      context: MemberErrorContext.otpSend,
    );
    expect(account.title, 'You already have a TouristSaver account.');

    final payment = MemberErrorPresenter.present(
      code: 'PAYMENT_FAILED',
      context: MemberErrorContext.paymentConfirmation,
    );
    expect(payment.message, contains('do not pay again'));
  });

  test('unknown code is retained internally but never displayed', () {
    final error = MemberErrorPresenter.present(
      code: 'FUTURE_BACKEND_SECRET_123',
      context: MemberErrorContext.registration,
    );
    expect(error.technicalCode, 'FUTURE_BACKEND_SECRET_123');
    expect(error.displayText, isNot(contains('FUTURE_BACKEND_SECRET_123')));
    expect(error.title, 'Something went wrong.');
  });

  test('context mapping overrides global mapping', () {
    final promo = MemberErrorPresenter.present(
      code: 'MEMBER_PREMIUM_CODE_NOT_VALID',
      context: MemberErrorContext.promoApply,
    );
    final registration = MemberErrorPresenter.present(
      code: 'MEMBER_PREMIUM_CODE_NOT_VALID',
      context: MemberErrorContext.registration,
    );
    expect(promo.title, 'This promo code is no longer valid.');
    expect(registration.title, 'This invitation is no longer available.');
  });

  test('explicit approved backend text takes precedence', () {
    final error = ErrorResModel.fromJson({
      'code': 'OTP_VERIFY_FAILED',
      'memberFacing': {
        'title': 'Approved title',
        'message': 'Approved member instruction',
      },
    });
    final presentation = MemberErrorPresenter.present(
      code: error.technicalCode,
      context: MemberErrorContext.otpVerify,
      approvedTitle: error.memberFacingTitle,
      approvedMessage: error.memberFacingMessage,
    );
    expect(presentation.title, 'Approved title');
    expect(presentation.message, 'Approved member instruction');
    expect(presentation.technicalCode, 'OTP_VERIFY_FAILED');
  });

  test('untranslated legacy code-shaped message is usable as a code', () {
    final legacy = ErrorResModel.fromJson({
      'message': 'DEFAULT_MEMBERSHIP_ISSUER_NOT_CONFIGURED',
    });
    final english = ErrorResModel.fromJson({
      'message': 'Issuer country did not match',
    });
    expect(legacy.technicalCode, 'DEFAULT_MEMBERSHIP_ISSUER_NOT_CONFIGURED');
    expect(english.technicalCode, isNull);
  });
}
