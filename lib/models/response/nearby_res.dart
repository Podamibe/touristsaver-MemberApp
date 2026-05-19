import 'dart:convert';

NearByLocationResModel nearByLocationResModelFromJson(String str) =>
    NearByLocationResModel.fromJson(json.decode(str));

NearByLocationResModel nearByLocationResModelFromPostCallJson(String str) =>
    NearByLocationResModel.fromPostCallJson(json.decode(str));

class NearByLocationResModel {
  NearByLocationResModel({
    this.status,
    this.data,
  });

  final String? status;
  final List<Datum>? data;

  factory NearByLocationResModel.fromJson(Map<String, dynamic> json) =>
      NearByLocationResModel(
        status: json["status"],
        data: json["data"] == null
            ? null
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  factory NearByLocationResModel.fromPostCallJson(Map<String, dynamic> json) =>
      NearByLocationResModel(
        status: json["status"],
        data: json["data"] == null
            ? null
            : List<Datum>.from(
                json["data"].map((x) => Datum.fromPostCallJson(x))),
      );
}

class Datum {
  Datum({
    this.merchantImageInfoId,
    this.merchantImageInfoLogoUrl,
    this.merchantImageInfoSlider1,
    this.merchantImageInfoSlider2,
    this.merchantImageInfoSlider3,
    this.merchantImageInfoSlider4,
    this.merchantImageInfoSlider5,
    this.merchantImageInfoSlider6,
    this.merchantImageInfoCreatedAt,
    this.merchantImageInfoMerchantId,
    this.id,
    this.merchantName,
    this.contactPersonFirstName,
    this.contactPersonLastName,
    this.merchantEmail,
    this.merchantPhoneNumber,
    this.email,
    this.password,
    this.phoneNumber,
    this.businessRegistrationNumber,
    this.latitude,
    this.longitude,
    this.buildingNo,
    this.streetInfo,
    this.registrationIsComplete,
    this.registrationCompletedStep,
    this.transactionCode,
    this.isApproved,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.countryId,
    this.regionId,
    this.areaId,
    this.stateId,
    this.whiteLabelId,
    this.merchantPackageId,
    this.signerId,
    this.signerType,
    this.postalCodeId,
    this.memberAsRefererId,
    this.isPremium,
    this.charityId,
    this.isPending,
    this.postalCodeUser,
    this.packageExpirydate,
    this.maxDiscount,
    this.favoriteMerchant,
    this.isAgreementComplete,
    this.isPopularFlag,
    this.popularOrder,
    this.rejectReason,
    this.registrationStatus,
    this.agreedTermAndCondition,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    this.merchantListingType,
    this.isOfficialTsdcMerchant,
    this.canRedeemTsdcSavings,
    this.externalUrlLabel,
    this.statename,
    this.countryname,
    this.distance,
  });

  final int? merchantImageInfoId;
  final String? merchantImageInfoLogoUrl;
  final String? merchantImageInfoSlider1;
  final String? merchantImageInfoSlider2;
  final String? merchantImageInfoSlider3;
  final String? merchantImageInfoSlider4;
  final String? merchantImageInfoSlider5;
  final String? merchantImageInfoSlider6;
  final DateTime? merchantImageInfoCreatedAt;
  final int? merchantImageInfoMerchantId;
  final int? id;
  final String? merchantName;
  final String? contactPersonFirstName;
  final String? contactPersonLastName;
  final String? merchantEmail;
  final String? merchantPhoneNumber;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? businessRegistrationNumber;
  final double? latitude;
  final double? longitude;
  final String? buildingNo;
  final String? streetInfo;
  final bool? registrationIsComplete;
  final int? registrationCompletedStep;
  final String? transactionCode;
  final bool? isApproved;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? countryId;
  final int? regionId;
  final int? areaId;
  final int? stateId;
  final dynamic whiteLabelId;
  final int? merchantPackageId;
  final int? signerId;
  final String? signerType;
  final int? postalCodeId;
  final dynamic memberAsRefererId;
  final bool? isPremium;
  final int? charityId;
  final bool? isPending;
  final String? postalCodeUser;
  final dynamic packageExpirydate;
  final double? maxDiscount;
  final int? favoriteMerchant;
  final bool? isAgreementComplete;
  final bool? isPopularFlag;
  final dynamic popularOrder;
  final dynamic rejectReason;
  final String? registrationStatus;
  final bool? agreedTermAndCondition;
  final dynamic stripeSubscriptionId;
  final dynamic stripeCustomerId;
  final String? merchantListingType;
  final bool? isOfficialTsdcMerchant;
  final bool? canRedeemTsdcSavings;
  final String? externalUrlLabel;
  final String? statename;
  final String? countryname;
  final double? distance;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        merchantImageInfoId: json["merchantImageInfo_id"],
        merchantImageInfoLogoUrl: json["merchantImageInfo_logoUrl"],
        merchantImageInfoSlider1: json["merchantImageInfo_slider1"],
        merchantImageInfoSlider2: json["merchantImageInfo_slider2"],
        merchantImageInfoSlider3: json["merchantImageInfo_slider3"],
        merchantImageInfoSlider4: json["merchantImageInfo_slider4"],
        merchantImageInfoSlider5: json["merchantImageInfo_slider5"],
        merchantImageInfoSlider6: json["merchantImageInfo_slider6"],
        merchantImageInfoCreatedAt: json["merchantImageInfo_createdAt"] == null
            ? null
            : DateTime.parse(json["merchantImageInfo_createdAt"]),
        merchantImageInfoMerchantId: json["merchantImageInfo_merchantId"],
        id: json["id"],
        merchantName: json["merchantName"],
        contactPersonFirstName: json["contactPersonFirstName"],
        contactPersonLastName: json["contactPersonLastName"],
        merchantEmail: json["merchantEmail"],
        merchantPhoneNumber: json["merchantPhoneNumber"],
        email: json["email"],
        password: json["password"],
        phoneNumber: json["phoneNumber"],
        businessRegistrationNumber: json["businessRegistrationNumber"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        buildingNo: json["buildingNo"],
        streetInfo: json["streetInfo"],
        registrationIsComplete: json["registrationIsComplete"],
        registrationCompletedStep: json["registrationCompletedStep"],
        transactionCode: json["transactionCode"],
        isApproved: json["isApproved"],
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        countryId: json["countryId"],
        regionId: json["regionId"],
        areaId: json["areaId"],
        stateId: json["stateId"],
        whiteLabelId: json["whiteLabelId"],
        merchantPackageId: json["merchantPackageId"],
        signerId: json["signerId"],
        signerType: json["signerType"],
        postalCodeId: json["postalCodeId"],
        memberAsRefererId: json["memberAsRefererId"],
        isPremium: json["isPremium"],
        charityId: json["charityId"],
        isPending: json["isPending"],
        postalCodeUser: json["postalCodeUser"],
        packageExpirydate: json["packageExpirydate"],
        maxDiscount: _doubleFromJson(json["maxDiscount"]),
        favoriteMerchant: json["favoritemerchant"],
        isAgreementComplete: json["isAgreementComplete"],
        isPopularFlag: json["isPopularFlag"],
        popularOrder: json["popularOrder"],
        rejectReason: json["rejectReason"],
        registrationStatus: json["registrationStatus"],
        agreedTermAndCondition: json["agreedTermAndCondition"],
        stripeSubscriptionId: json["stripeSubscriptionId"],
        stripeCustomerId: json["stripeCustomerId"],
        merchantListingType: _stringFromJson(json["merchantListingType"]),
        isOfficialTsdcMerchant: _boolFromJson(json["isOfficialTsdcMerchant"]),
        canRedeemTsdcSavings: _boolFromJson(json["canRedeemTsdcSavings"]),
        externalUrlLabel: _stringFromJson(json["externalUrlLabel"]),
        statename: json["statename"],
        countryname: json["countryname"],
        distance: _doubleFromJson(json["distance"]),
      );

  factory Datum.fromPostCallJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        merchantName: json["merchantname"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        maxDiscount: _doubleFromJson(json["maxdiscount"]),
        favoriteMerchant: json["favoritemerchant"],
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
