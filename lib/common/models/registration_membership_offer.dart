import 'package:intl/intl.dart';

class RegistrationMembershipOffer {
  const RegistrationMembershipOffer({
    required this.codeType,
    required this.complimentary,
    this.membershipPackageId,
    this.discountPercentage,
    this.baseAmount,
    this.payableAmount,
    this.currency,
  });

  final String codeType;
  final bool complimentary;
  final int? membershipPackageId;
  final double? discountPercentage;
  final double? baseAmount;
  final double? payableAmount;
  final String? currency;

  factory RegistrationMembershipOffer.fromJson(Map<String, dynamic> json) =>
      RegistrationMembershipOffer(
        codeType: json['codeType']?.toString() ?? '',
        complimentary: json['complimentary'] == true,
        membershipPackageId: _integer(json['membershipPackageId']),
        discountPercentage: _number(json['discountPercentage']),
        baseAmount: _number(json['baseAmount']),
        payableAmount: _number(json['payableAmount']),
        currency: json['currency']?.toString(),
      );

  String? get displayLine {
    if (codeType != 'multi_use_premium_code' &&
        codeType != 'legacy_premium_code') {
      return null;
    }
    if (complimentary || discountPercentage == 100 || payableAmount == 0) {
      return 'Complimentary Premium Membership';
    }
    if (discountPercentage == null ||
        payableAmount == null ||
        currency == null ||
        currency!.isEmpty) {
      return null;
    }
    final currencySymbol = switch (currency!.toUpperCase()) {
      'AUD' => r'A$',
      'NZD' => r'NZ$',
      'CAD' => r'C$',
      'USD' => r'$',
      _ => NumberFormat.simpleCurrency(name: currency, locale: 'en_US')
          .currencySymbol,
    };
    final format = NumberFormat.currency(
      name: currency,
      symbol: currencySymbol,
      locale: 'en_US',
    );
    final amount = payableAmount!;
    final formatted = amount == amount.roundToDouble()
        ? NumberFormat.currency(
            name: currency,
            symbol: currencySymbol,
            decimalDigits: 0,
            locale: 'en_US',
          ).format(amount)
        : format.format(amount);
    return '${discountPercentage!.toStringAsFixed(0)}% discount · Now $formatted';
  }

  static int? _integer(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');

  static double? _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
}

class RegistrationPromoVerification {
  const RegistrationPromoVerification({
    required this.verified,
    this.offer,
  });

  const RegistrationPromoVerification.empty()
      : verified = false,
        offer = null;

  final bool verified;
  final RegistrationMembershipOffer? offer;

  RegistrationPromoVerification edited() =>
      const RegistrationPromoVerification.empty();
}
