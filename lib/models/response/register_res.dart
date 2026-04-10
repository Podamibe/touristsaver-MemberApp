// To parse this JSON data, do
//
//     final registerResModel = registerResModelFromJson(jsonString);

import 'dart:convert';

RegisterResModel registerResModelFromJson(String str) =>
    RegisterResModel.fromJson(json.decode(str));

String registerResModelToJson(RegisterResModel data) =>
    json.encode(data.toJson());

class RegisterResModel {
  final String? status;
  final Data? data;

  RegisterResModel({
    this.status,
    this.data,
  });

  factory RegisterResModel.fromJson(Map<String, dynamic> json) =>
      RegisterResModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class Data {
  final bool? showFreePiiinks;
  final String? accessToken;
  final MemberInfo? memberInfo;
  final UniversalWallet? universalWallet;
  final bool? premiumCodeIsApplied;
  final bool? premiumCodeIsPaid;
  final int? packageId;
  final String? discount;

  Data({
    this.showFreePiiinks,
    this.accessToken,
    this.memberInfo,
    this.universalWallet,
    this.premiumCodeIsApplied,
    this.premiumCodeIsPaid,
    this.packageId,
    this.discount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        showFreePiiinks: json['showFreePiiinks'],
        accessToken: json["accessToken"],
        memberInfo: json["memberInfo"] == null
            ? null
            : MemberInfo.fromJson(json["memberInfo"]),
        universalWallet: json["universalWallet"] == null
            ? null
            : UniversalWallet.fromJson(json["universalWallet"]),
        premiumCodeIsApplied: json["premiumCodeIsApplied"],
        premiumCodeIsPaid: json["premiumCodeIsPaid"],
        packageId: json["packageId"],
        discount: json["discount"],
      );

  Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
        "showFreePiiinks": showFreePiiinks,
        "memberInfo": memberInfo?.toJson(),
        "universalWallet": universalWallet?.toJson(),
        "premiumCodeIsApplied": premiumCodeIsApplied,
        "premiumCodeIsPaid": premiumCodeIsPaid,
        "packageId": packageId,
        "discount": discount,
      };
}

class MemberInfo {
  final String? firstname;
  final String? lastname;
  final String? uniqueMemberCode;
  final String? email;
  final String? password;
  final String? postalCode;
  final String? phoneNumber;
  final String? memberType;
  final DateTime? turnedToPremiumDate;
  final bool? isActive;
  final int? originCountryId;
  final int? countryId;
  final int? stateId;
  final int? issuerCodeId;
  final int? whiteLabelId;
  final int? issuerId;
  final String? issuerType;
  final dynamic charityId;
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MemberInfo({
    this.firstname,
    this.lastname,
    this.uniqueMemberCode,
    this.email,
    this.password,
    this.postalCode,
    this.phoneNumber,
    this.memberType,
    this.turnedToPremiumDate,
    this.isActive,
    this.originCountryId,
    this.countryId,
    this.stateId,
    this.issuerCodeId,
    this.whiteLabelId,
    this.issuerId,
    this.issuerType,
    this.charityId,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) => MemberInfo(
        firstname: json["firstname"],
        lastname: json["lastname"],
        uniqueMemberCode: json["uniqueMemberCode"],
        email: json["email"],
        password: json["password"],
        postalCode: json["postalCode"],
        phoneNumber: json["phoneNumber"],
        memberType: json["memberType"],
        turnedToPremiumDate: json["turnedToPremiumDate"] == null
            ? null
            : DateTime.parse(json["turnedToPremiumDate"]),
        isActive: json["isActive"],
        originCountryId: json["originCountryId"],
        countryId: json["countryId"],
        stateId: json["stateId"],
        issuerCodeId: json["issuerCodeId"],
        whiteLabelId: json["whiteLabelId"],
        issuerId: json["issuerId"],
        issuerType: json["issuerType"],
        charityId: json["charityId"],
        id: json["id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "firstname": firstname,
        "lastname": lastname,
        "uniqueMemberCode": uniqueMemberCode,
        "email": email,
        "password": password,
        "postalCode": postalCode,
        "phoneNumber": phoneNumber,
        "memberType": memberType,
        "turnedToPremiumDate": turnedToPremiumDate?.toIso8601String(),
        "isActive": isActive,
        "originCountryId": originCountryId,
        "countryId": countryId,
        "stateId": stateId,
        "issuerCodeId": issuerCodeId,
        "whiteLabelId": whiteLabelId,
        "issuerId": issuerId,
        "issuerType": issuerType,
        "charityId": charityId,
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class UniversalWallet {
  final double? balance;
  final DateTime? premiumExpiryDate;
  final int? memberId;
  final int? countryId;
  final DateTime? deletedAt;
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UniversalWallet({
    this.balance,
    this.premiumExpiryDate,
    this.memberId,
    this.countryId,
    this.deletedAt,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory UniversalWallet.fromJson(Map<String, dynamic> json) =>
      UniversalWallet(
        balance: json["balance"]?.toDouble(),
        premiumExpiryDate: json["premiumExpiryDate"] == null
            ? null
            : DateTime.parse(json["premiumExpiryDate"]),
        memberId: json["memberId"],
        countryId: json["countryId"],
        deletedAt: json["deletedAt"] == null
            ? null
            : DateTime.parse(json["deletedAt"]),
        id: json["id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "premiumExpiryDate": premiumExpiryDate?.toIso8601String(),
        "memberId": memberId,
        "countryId": countryId,
        "deletedAt": deletedAt?.toIso8601String(),
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
