class ApplyPiiinkByMerchantReqModel {
  const ApplyPiiinkByMerchantReqModel({
    required this.merchantId,
    required this.amount,
    this.lang,
    this.latitude,
    this.longitude,
  });

  final int merchantId;
  final double amount;
  final String? lang;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'merchantId': merchantId,
        'amount': amount,
        'lang': lang,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}
