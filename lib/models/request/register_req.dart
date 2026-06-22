import 'dart:convert';

String registerReqModelToJson(RegisterReqModel data) =>
    json.encode(data.toJson());

class RegisterReqModel {
  RegisterReqModel(
      {required this.smsotp,
      required this.charityId,
      required this.phoneVerifiedBy,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.postalCode,
      required this.phoneNumber,
      required this.countryId,
      required this.stateId,
      required this.issuerCode,
      required this.password,
      required this.confirmPassword,
      required this.memberPremiumCode,
      required this.memberReferralCode,
      required this.phoneNumberPrefix});

  final String phoneNumberPrefix;
  final String smsotp;
  final String firstname;
  final String lastname;
  final String email;
  final String postalCode;
  final String phoneNumber;
  final int? charityId;
  final String phoneVerifiedBy;
  final int countryId;
  final int? stateId;
  final dynamic issuerCode;
  final String password;
  final String confirmPassword;
  final dynamic memberPremiumCode;
  final dynamic memberReferralCode;

  Map<String, dynamic> toJson() => {
        "phoneNumberPrefix": phoneNumberPrefix,
        "SMSOTP": smsotp,
        "phoneVerifiedBy": phoneVerifiedBy,
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "postalCode": postalCode,
        "phoneNumber": phoneNumber,
        "countryId": countryId,
        if (stateId != null) "stateId": stateId,
        "charityId": charityId,
        "issuerCode": issuerCode == 'null' ? null : issuerCode,
        "password": password,
        "confirmPassword": confirmPassword,
        "memberPremiumCode":
            memberPremiumCode == 'null' ? null : memberPremiumCode,
        "memberReferralCode":
            memberReferralCode == 'null' ? null : memberReferralCode,
      };
}
