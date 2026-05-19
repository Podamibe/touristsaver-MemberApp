import 'dart:convert';

MerchantDetailResModel merchantDetailResModelFromJson(String str) =>
    MerchantDetailResModel.fromJson(json.decode(str));

class MerchantDetailResModel {
  MerchantDetailResModel({
    this.status,
    this.data,
  });

  final String? status;
  final Data? data;

  factory MerchantDetailResModel.fromJson(Map<String, dynamic> json) =>
      MerchantDetailResModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
}

class Data {
  Data({
    this.id,
    this.merchantName,
    this.maxDiscount,
    this.contactPersonFirstName,
    this.contactPersonLastName,
    this.merchantEmail,
    this.merchantPhoneNumber,
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
    this.merchantListingType,
    this.isOfficialTsdcMerchant,
    this.canRedeemTsdcSavings,
    this.externalUrl,
    this.externalUrlLabel,
    this.isPremium,
    this.packageExpirydate,
    this.signerId,
    this.signerType,
    this.charityId,
    this.merchantWebsiteInfo,
    this.country,
    this.state,
    this.discountAtHourOfDay,
    this.merchantImageInfo,
  });

  final int? id;
  final String? merchantName;
  final double? maxDiscount;
  final String? contactPersonFirstName;
  final String? contactPersonLastName;
  final String? merchantEmail;
  final String? merchantPhoneNumber;
  final String? email;
  final dynamic stripeSubscriptionId;
  final dynamic stripeCustomerId;
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
  final DateTime? createdAt;
  final int? countryId;
  final int? stateId;
  final int? regionId;
  final int? areaId;
  final dynamic postalCodeUser;
  final dynamic postalCodeId;
  final dynamic memberAsRefererId;
  final dynamic whiteLabelId;
  final int? merchantPackageId;
  final String? merchantListingType;
  final bool? isOfficialTsdcMerchant;
  final bool? canRedeemTsdcSavings;
  final String? externalUrl;
  final String? externalUrlLabel;
  final bool? isPremium;
  final dynamic packageExpirydate;
  final int? signerId;
  final String? signerType;
  final int? charityId;
  final MerchantWebsiteInfo? merchantWebsiteInfo;
  final Country? country;
  final States? state;
  final double? discountAtHourOfDay;
  final MerchantImageInfo? merchantImageInfo;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        merchantName: json["merchantName"],
        maxDiscount: _doubleFromJson(json["maxDiscount"]),
        contactPersonFirstName: json["contactPersonFirstName"],
        contactPersonLastName: json["contactPersonLastName"],
        merchantEmail: json["merchantEmail"],
        merchantPhoneNumber: json["merchantPhoneNumber"],
        email: json["email"],
        stripeSubscriptionId: json["stripeSubscriptionId"],
        stripeCustomerId: json["stripeCustomerId"],
        phoneNumber: json["phoneNumber"],
        businessRegistrationNumber: json["businessRegistrationNumber"],
        latlon: json["latlon"] == null
            ? null
            : List<double>.from(json["latlon"].map((x) => x.toDouble())),
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
        merchantListingType: _stringFromJson(json["merchantListingType"]),
        isOfficialTsdcMerchant: _boolFromJson(json["isOfficialTsdcMerchant"]),
        canRedeemTsdcSavings: _boolFromJson(json["canRedeemTsdcSavings"]),
        externalUrl: _stringFromJson(json["externalUrl"]),
        externalUrlLabel: _stringFromJson(json["externalUrlLabel"]),
        isPremium: json["isPremium"],
        packageExpirydate: json["packageExpirydate"],
        signerId: json["signerId"],
        signerType: json["signerType"],
        charityId: json["charityId"],
        merchantWebsiteInfo: json["__merchantWebsiteInfo__"] == null
            ? null
            : MerchantWebsiteInfo.fromJson(json["__merchantWebsiteInfo__"]),
        country: json["__country__"] == null
            ? null
            : Country.fromJson(json["__country__"]),
        state: json["__state__"] == null
            ? null
            : States.fromJson(json["__state__"]),
        discountAtHourOfDay: _doubleFromJson(json["discountAtHourOfDay"]),
        merchantImageInfo: json["__merchantImageInfo__"] == null
            ? null
            : MerchantImageInfo.fromJson(json["__merchantImageInfo__"]),
      );
}

double? _doubleFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _boolFromJson(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final String normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

String? _stringFromJson(dynamic value) {
  if (value == null) return null;
  final String stringValue = value.toString().trim();
  if (stringValue.isEmpty || stringValue.toLowerCase() == 'null') return null;
  return stringValue;
}

class Country {
  Country({
    this.id,
    this.countryName,
    this.countryShortName,
    this.imageUrl,
    this.phonePrefix,
    this.currencyName,
    this.currencySymbol,
    this.symbolIsPrefix,
    this.taxationUnitValue,
    this.isPiiinkCountry,
    this.isAssignedToOwner,
    this.createdAt,
  });

  final int? id;
  final String? countryName;
  final String? countryShortName;
  final String? imageUrl;
  final String? phonePrefix;
  final String? currencyName;
  final String? currencySymbol;
  final bool? symbolIsPrefix;
  final double? taxationUnitValue;
  final bool? isPiiinkCountry;
  final bool? isAssignedToOwner;
  final DateTime? createdAt;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        countryName: json["countryName"],
        countryShortName: json["countryShortName"],
        imageUrl: json["imageUrl"],
        phonePrefix: json["phonePrefix"],
        currencyName: json["currencyName"],
        currencySymbol: json["currencySymbol"],
        symbolIsPrefix: json["symbolIsPrefix"],
        taxationUnitValue: json["taxationUnitValue"]?.toDouble(),
        isPiiinkCountry: json["isPiiinkCountry"],
        isAssignedToOwner: json["isAssignedToOwner"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
      );
}

class MerchantWebsiteInfo {
  MerchantWebsiteInfo({
    this.id,
    this.facebookLink,
    this.instagramLink,
    this.openingHourInfo,
    this.merchantDescription,
    this.websiteLink,
    this.isRecommended,
    this.recommendedOrder,
    this.createdAt,
    this.merchantId,
  });

  final int? id;
  final String? facebookLink;
  final String? instagramLink;
  final String? openingHourInfo;
  final String? merchantDescription;
  final String? websiteLink;
  final bool? isRecommended;
  final dynamic recommendedOrder;
  final DateTime? createdAt;
  final int? merchantId;

  factory MerchantWebsiteInfo.fromJson(Map<String, dynamic> json) =>
      MerchantWebsiteInfo(
        id: json["id"],
        facebookLink: json["facebookLink"],
        instagramLink: json["instagramLink"],
        openingHourInfo: json["openingHourInfo"],
        merchantDescription: json["merchantDescription"],
        websiteLink: json["websiteLink"],
        isRecommended: json["isRecommended"],
        recommendedOrder: json["recommendedOrder"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        merchantId: json["merchantId"],
      );
}

class States {
  States({
    this.id,
    this.stateName,
    this.stateShortName,
    this.imageUrl,
    this.isPiiinkState,
    this.isAssignedToOwner,
    this.createdAt,
    this.countryId,
  });

  final int? id;
  final String? stateName;
  final String? stateShortName;
  final String? imageUrl;
  final bool? isPiiinkState;
  final bool? isAssignedToOwner;
  final DateTime? createdAt;
  final int? countryId;

  factory States.fromJson(Map<String, dynamic> json) => States(
        id: json["id"],
        stateName: json["stateName"],
        stateShortName: json["stateShortName"],
        imageUrl: json["imageUrl"],
        isPiiinkState: json["isPiiinkState"],
        isAssignedToOwner: json["isAssignedToOwner"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        countryId: json["countryId"],
      );
}

class MerchantImageInfo {
  MerchantImageInfo({
    this.id,
    this.logoUrl,
    this.slider1,
    this.slider2,
    this.slider3,
    this.slider4,
    this.slider5,
    this.slider6,
    this.createdAt,
    this.merchantId,
  });

  final int? id;
  final String? logoUrl;
  final String? slider1;
  final String? slider2;
  final String? slider3;
  final String? slider4;
  final String? slider5;
  final String? slider6;
  final DateTime? createdAt;
  final int? merchantId;

  factory MerchantImageInfo.fromJson(Map<String, dynamic> json) =>
      MerchantImageInfo(
        id: json["id"],
        logoUrl: json["logoUrl"],
        slider1: json["slider1"],
        slider2: json["slider2"],
        slider3: json["slider3"],
        slider4: json["slider4"],
        slider5: json["slider5"],
        slider6: json["slider6"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        merchantId: json["merchantId"],
      );
}
