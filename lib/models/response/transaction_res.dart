// To parse this JSON data, do
//
//     final transactionResModel = transactionResModelFromJson(jsonString);

import 'dart:convert';

TransactionResModel transactionResModelFromJson(String str) =>
    TransactionResModel.fromJson(json.decode(str));

String transactionResModelToJson(TransactionResModel data) =>
    json.encode(data.toJson());

class TransactionResModel {
  TransactionResModel({
    this.status,
    this.data,
    this.hasMore,
    this.count,
    this.totalCount,
    this.page,
  });

  final String? status;
  final Map<String, List<Datum>>? data;
  final bool? hasMore;
  final int? count;
  final int? totalCount;
  final int? page;

  factory TransactionResModel.fromJson(Map<String, dynamic> json) =>
      TransactionResModel(
        status: json["status"],
        data: Map.from(json["data"]!).map((k, v) =>
            MapEntry<String, List<Datum>>(
                k, List<Datum>.from(v.map((x) => Datum.fromJson(x))))),
        hasMore: json["hasMore"],
        count: json["count"],
        totalCount: json["totalCount"],
        page: json["page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": Map.from(data!).map((k, v) => MapEntry<String, dynamic>(
            k, List<dynamic>.from(v.map((x) => x.toJson())))),
        "hasMore": hasMore,
        "count": count,
        "totalCount": totalCount,
        "page": page,
      };
}

class Datum {
  Datum({
    this.id,
    this.transactionId,
    this.totalAmountInUsd,
    this.totalAmount,
    this.transactionCurrency,
    this.discountPercentage,
    this.transactionAmount,
    this.transactionAmountInUsd,
    this.piiinkWalletType,
    this.transactionFeePercentage,
    this.transactionFeeAmount,
    this.transactionFeeAmountInUsd,
    this.discountAmount,
    this.discountAmountInUsd,
    this.status,
    this.isPremiumMember,
    this.rebateAmount,
    this.merchantConversionRateInUsd,
    this.membersIssuerConversionRateInUsd,
    this.transactionDate,
    this.memberId,
    this.merchantId,
    this.stateId,
    this.regionId,
    this.areaId,
    this.merchantCountryId,
    this.issuerCountryId,
    this.memberCountryId,
    this.memberBelongingToWhiteLabelId,
    this.isMerchantWhiteLabel,
    this.isMemberWhiteLabel,
    this.merchantBelongingToWhiteLabelId,
    this.signerId,
    this.signerType,
    this.issuerId,
    this.issuerType,
    this.charityFrom,
    this.charityId,
    this.isMerchantMadeByCp,
    this.isMemberMadeByCp,
    this.merchantImageInfo,
    this.merchant,
  });

  final int? id;
  final String? transactionId;
  final double? totalAmountInUsd;
  final double? totalAmount;
  final String? transactionCurrency;
  final double? discountPercentage;
  final double? transactionAmount;
  final double? transactionAmountInUsd;
  final String? piiinkWalletType;
  final double? transactionFeePercentage;
  final double? transactionFeeAmount;
  final double? transactionFeeAmountInUsd;
  final double? discountAmount;
  final double? discountAmountInUsd;
  final String? status;
  final bool? isPremiumMember;
  final double? rebateAmount;
  final double? merchantConversionRateInUsd;
  final double? membersIssuerConversionRateInUsd;
  final DateTime? transactionDate;
  final int? memberId;
  final int? merchantId;
  final int? stateId;
  final int? regionId;
  final int? areaId;
  final int? merchantCountryId;
  final int? issuerCountryId;
  final int? memberCountryId;
  final dynamic memberBelongingToWhiteLabelId;
  final bool? isMerchantWhiteLabel;
  final bool? isMemberWhiteLabel;
  final int? merchantBelongingToWhiteLabelId;
  final int? signerId;
  final String? signerType;
  final int? issuerId;
  final String? issuerType;
  final String? charityFrom;
  final int? charityId;
  final bool? isMerchantMadeByCp;
  final bool? isMemberMadeByCp;
  final MerchantImageInfo? merchantImageInfo;
  final Merchant? merchant;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        transactionId: json["transactionId"],
        totalAmountInUsd: json["totalAmountInUSD"]?.toDouble(),
        totalAmount: json["totalAmount"]?.toDouble(),
        transactionCurrency: json["transactionCurrency"],
        discountPercentage: json["discountPercentage"]?.toDouble(),
        transactionAmount: json["transactionAmount"]?.toDouble(),
        transactionAmountInUsd: json["transactionAmountInUSD"]?.toDouble(),
        piiinkWalletType: json["piiinkWalletType"],
        transactionFeePercentage: json["transactionFeePercentage"]?.toDouble(),
        transactionFeeAmount: json["transactionFeeAmount"]?.toDouble(),
        transactionFeeAmountInUsd:
            json["transactionFeeAmountInUSD"]?.toDouble(),
        discountAmount: json["discountAmount"]?.toDouble(),
        discountAmountInUsd: json["discountAmountInUSD"]?.toDouble(),
        status: json["status"],
        isPremiumMember: json["isPremiumMember"],
        rebateAmount: json["rebateAmount"]?.toDouble(),
        merchantConversionRateInUsd:
            json["merchantConversionRateInUSD"]?.toDouble(),
        membersIssuerConversionRateInUsd:
            json["membersIssuerConversionRateInUSD"]?.toDouble(),
        transactionDate: json["transactionDate"] == null
            ? null
            : DateTime.parse(json["transactionDate"]),
        memberId: json["memberId"],
        merchantId: json["merchantId"],
        stateId: json["stateId"],
        regionId: json["regionId"],
        areaId: json["areaId"],
        merchantCountryId: json["merchantCountryId"],
        issuerCountryId: json["issuerCountryId"],
        memberCountryId: json["memberCountryId"],
        memberBelongingToWhiteLabelId: json["memberBelongingToWhiteLabelId"],
        isMerchantWhiteLabel: json["isMerchantWhiteLabel"],
        isMemberWhiteLabel: json["isMemberWhiteLabel"],
        merchantBelongingToWhiteLabelId:
            json["merchantBelongingToWhiteLabelId"],
        signerId: json["signerId"],
        signerType: json["signerType"],
        issuerId: json["issuerId"],
        issuerType: json["issuerType"],
        charityFrom: json["charityFrom"],
        charityId: json["charityId"],
        isMerchantMadeByCp: json["isMerchantMadeByCP"],
        isMemberMadeByCp: json["isMemberMadeByCP"],
        merchantImageInfo: json["__merchantImageInfo__"] == null
            ? null
            : MerchantImageInfo.fromJson(json["__merchantImageInfo__"]),
        merchant: json["__merchant__"] == null
            ? null
            : Merchant.fromJson(json["__merchant__"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "transactionId": transactionId,
        "totalAmountInUSD": totalAmountInUsd,
        "totalAmount": totalAmount,
        "transactionCurrency": transactionCurrency,
        "discountPercentage": discountPercentage,
        "transactionAmount": transactionAmount,
        "transactionAmountInUSD": transactionAmountInUsd,
        "piiinkWalletType": piiinkWalletType,
        "transactionFeePercentage": transactionFeePercentage,
        "transactionFeeAmount": transactionFeeAmount,
        "transactionFeeAmountInUSD": transactionFeeAmountInUsd,
        "discountAmount": discountAmount,
        "discountAmountInUSD": discountAmountInUsd,
        "status": status,
        "isPremiumMember": isPremiumMember,
        "rebateAmount": rebateAmount,
        "merchantConversionRateInUSD": merchantConversionRateInUsd,
        "membersIssuerConversionRateInUSD": membersIssuerConversionRateInUsd,
        "transactionDate": transactionDate?.toIso8601String(),
        "memberId": memberId,
        "merchantId": merchantId,
        "stateId": stateId,
        "regionId": regionId,
        "areaId": areaId,
        "merchantCountryId": merchantCountryId,
        "issuerCountryId": issuerCountryId,
        "memberCountryId": memberCountryId,
        "memberBelongingToWhiteLabelId": memberBelongingToWhiteLabelId,
        "isMerchantWhiteLabel": isMerchantWhiteLabel,
        "isMemberWhiteLabel": isMemberWhiteLabel,
        "merchantBelongingToWhiteLabelId": merchantBelongingToWhiteLabelId,
        "signerId": signerId,
        "signerType": signerType,
        "issuerId": issuerId,
        "issuerType": issuerType,
        "charityFrom": charityFrom,
        "charityId": charityId,
        "isMerchantMadeByCP": isMerchantMadeByCp,
        "isMemberMadeByCP": isMemberMadeByCp,
        "__merchantImageInfo__": merchantImageInfo?.toJson(),
        "__merchant__": merchant?.toJson(),
      };
}

class Merchant {
  Merchant({
    this.id,
    this.merchantName,
    this.logoUrl,
    this.merchantImageInfo,
    this.maxDiscount,
    this.contactPersonFirstName,
    this.contactPersonLastName,
    this.merchantEmail,
    this.merchantPhoneNumber,
    this.username,
    this.email,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    this.phoneNumber,
    this.businessRegistrationNumber,
    this.latlon,
    this.buildingNo,
    this.streetInfo,
    this.city,
    this.registrationIsComplete,
    this.isAgreementComplete,
    this.registrationCompletedStep,
    this.rejectReason,
    this.registrationStatus,
    this.transactionCode,
    this.isPopularFlag,
    this.popularOrder,
    this.agreedTermAndCondition,
    this.isImported,
    this.emailSent,
    this.createdAt,
    this.countryId,
    this.stateId,
    this.regionId,
    this.areaId,
    this.postalCodeUser,
    this.postalCodeId,
    this.memberAsRefererId,
    this.whiteLabelId,
    this.merchantPackageId,
    this.isPremium,
    this.packageExpirydate,
    this.signerId,
    this.signerType,
    this.charityId,
  });

  final int? id;
  final String? merchantName;
  final String? logoUrl;
  final MerchantImageInfo? merchantImageInfo;
  final double? maxDiscount;
  final String? contactPersonFirstName;
  final String? contactPersonLastName;
  final String? merchantEmail;
  final String? merchantPhoneNumber;
  final String? username;
  final String? email;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;
  final String? phoneNumber;
  final String? businessRegistrationNumber;
  final List<double>? latlon;
  final String? buildingNo;
  final String? streetInfo;
  final String? city;
  final bool? registrationIsComplete;
  final bool? isAgreementComplete;
  final int? registrationCompletedStep;
  final dynamic rejectReason;
  final String? registrationStatus;
  final String? transactionCode;
  final bool? isPopularFlag;
  final int? popularOrder;
  final bool? agreedTermAndCondition;
  final bool? isImported;
  final bool? emailSent;
  final DateTime? createdAt;
  final int? countryId;
  final int? stateId;
  final int? regionId;
  final int? areaId;
  final String? postalCodeUser;
  final int? postalCodeId;
  final dynamic memberAsRefererId;
  final int? whiteLabelId;
  final int? merchantPackageId;
  final bool? isPremium;
  final dynamic packageExpirydate;
  final int? signerId;
  final String? signerType;
  final int? charityId;

  factory Merchant.fromJson(Map<String, dynamic> json) => Merchant(
        id: json["id"],
        merchantName: json["merchantName"],
        logoUrl: json["logoUrl"],
        merchantImageInfo: json["__merchantImageInfo__"] == null
            ? null
            : MerchantImageInfo.fromJson(json["__merchantImageInfo__"]),
        maxDiscount: json["maxDiscount"]?.toDouble(),
        contactPersonFirstName: json["contactPersonFirstName"],
        contactPersonLastName: json["contactPersonLastName"],
        merchantEmail: json["merchantEmail"],
        merchantPhoneNumber: json["merchantPhoneNumber"],
        username: json["username"],
        email: json["email"],
        stripeSubscriptionId: json["stripeSubscriptionId"],
        stripeCustomerId: json["stripeCustomerId"],
        phoneNumber: json["phoneNumber"],
        businessRegistrationNumber: json["businessRegistrationNumber"],
        latlon: json["latlon"] == null
            ? []
            : List<double>.from(json["latlon"]!.map((x) => x.toDouble())),
        buildingNo: json["buildingNo"],
        streetInfo: json["streetInfo"],
        city: json["city"],
        registrationIsComplete: json["registrationIsComplete"],
        isAgreementComplete: json["isAgreementComplete"],
        registrationCompletedStep: json["registrationCompletedStep"],
        rejectReason: json["rejectReason"],
        registrationStatus: json["registrationStatus"],
        transactionCode: json["transactionCode"],
        isPopularFlag: json["isPopularFlag"],
        popularOrder: json["popularOrder"],
        agreedTermAndCondition: json["agreedTermAndCondition"],
        isImported: json["isImported"],
        emailSent: json["emailSent"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        countryId: json["countryId"],
        stateId: json["stateId"],
        regionId: json["regionId"],
        areaId: json["areaId"],
        postalCodeUser: json["postalCodeUser"],
        postalCodeId: json["postalCodeId"],
        memberAsRefererId: json["memberAsRefererId"],
        whiteLabelId: json["whiteLabelId"],
        merchantPackageId: json["merchantPackageId"],
        isPremium: json["isPremium"],
        packageExpirydate: json["packageExpirydate"],
        signerId: json["signerId"],
        signerType: json["signerType"],
        charityId: json["charityId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "merchantName": merchantName,
        "logoUrl": logoUrl,
        "__merchantImageInfo__": merchantImageInfo?.toJson(),
        "maxDiscount": maxDiscount,
        "contactPersonFirstName": contactPersonFirstName,
        "contactPersonLastName": contactPersonLastName,
        "merchantEmail": merchantEmail,
        "merchantPhoneNumber": merchantPhoneNumber,
        "username": username,
        "email": email,
        "stripeSubscriptionId": stripeSubscriptionId,
        "stripeCustomerId": stripeCustomerId,
        "phoneNumber": phoneNumber,
        "businessRegistrationNumber": businessRegistrationNumber,
        "latlon":
            latlon == null ? [] : List<dynamic>.from(latlon!.map((x) => x)),
        "buildingNo": buildingNo,
        "streetInfo": streetInfo,
        "city": city,
        "registrationIsComplete": registrationIsComplete,
        "isAgreementComplete": isAgreementComplete,
        "registrationCompletedStep": registrationCompletedStep,
        "rejectReason": rejectReason,
        "registrationStatus": registrationStatus,
        "transactionCode": transactionCode,
        "isPopularFlag": isPopularFlag,
        "popularOrder": popularOrder,
        "agreedTermAndCondition": agreedTermAndCondition,
        "isImported": isImported,
        "emailSent": emailSent,
        "createdAt": createdAt?.toIso8601String(),
        "countryId": countryId,
        "stateId": stateId,
        "regionId": regionId,
        "areaId": areaId,
        "postalCodeUser": postalCodeUser,
        "postalCodeId": postalCodeId,
        "memberAsRefererId": memberAsRefererId,
        "whiteLabelId": whiteLabelId,
        "merchantPackageId": merchantPackageId,
        "isPremium": isPremium,
        "packageExpirydate": packageExpirydate,
        "signerId": signerId,
        "signerType": signerType,
        "charityId": charityId,
      };
}

class MerchantImageInfo {
  MerchantImageInfo({
    this.logoUrl,
    this.slider1,
    this.slider2,
    this.slider3,
    this.slider4,
    this.slider5,
  });

  final String? logoUrl;
  final String? slider1;
  final String? slider2;
  final String? slider3;
  final String? slider4;
  final String? slider5;

  factory MerchantImageInfo.fromJson(Map<String, dynamic> json) =>
      MerchantImageInfo(
        logoUrl: json["logoUrl"],
        slider1: json["slider1"],
        slider2: json["slider2"],
        slider3: json["slider3"],
        slider4: json["slider4"],
        slider5: json["slider5"],
      );

  Map<String, dynamic> toJson() => {
        "logoUrl": logoUrl,
        "slider1": slider1,
        "slider2": slider2,
        "slider3": slider3,
        "slider4": slider4,
        "slider5": slider5,
      };
}
