import 'dart:convert';
// import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/confirm_topup_req.dart';
import 'package:touristsaver/models/request/premium_validity_req.dart';
import 'package:touristsaver/models/request/reg_member_otp_req.dart';
import 'package:touristsaver/models/request/reg_top_up_req.dart';
import 'package:touristsaver/models/request/register_req.dart';
import 'package:touristsaver/models/request/resend_reg_num_otp_req.dart';
import 'package:touristsaver/models/response/check_issuer_res.dart';
import 'package:touristsaver/models/response/common_res.dart';
import 'package:touristsaver/models/response/get_app_slugs_res_model.dart';
import 'package:touristsaver/models/response/reg_topup_res.dart';
import 'package:touristsaver/models/response/register_res.dart';
import 'package:touristsaver/models/response/resend_reg_num_otp_res.dart';
import 'package:touristsaver/models/response/top_up_stripe_res.dart';

import '../../../constants/pref.dart';
import '../../../models/request/phone_otp_req.dart';
import '../../../models/response/country_wise_prefix_res_model.dart';
import '../../../models/response/sms_validation_res_model.dart';

class DioRegister {
  Future<GetAppSlugResModel?> getAppSlugMessages(String? slug) async {
    String lang = await Pref().readData(key: 'locale') ?? 'en';
    try {
      Dio dio = await getClientNoToken();
      Response<String> response =
          await dio.get('$appSlugMessageURL/$slug?lang=$lang');
      // log(response.data!);
      return getAppSlugResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  Future<CountryWisePrefixResModel?> countryPhonePrefix() async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(getAllPhonePrefix);
      // log(response.data!);
      return countryWisePrefixResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

//Get OTP type for DropDown
  Future<SmsValidationModel?> getOtpType() async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(verifyOTPMediumUrl);
      // log(response.data!);
      return smsValidationModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

//Premium Validity
  Future<CommonResModel?> premiumVal(
      {required PremiumValidityReqModel premiumValidityReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.post(
        premium,
        data: premiumValidityReqModel.toJson(),
      );
      return commonResModelFromJson(response.data!);
    } on DioException catch (e) {
      return commonResModelFromJson(e.response?.data);
    }
  }

  // Checks email and phone no
  Future<bool?> checkEmailAndPhoneNo(
      {required EmailMemberOtpReqModel emailmemberOtpReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      Response response = await dio.post(
        checkEmailAndPhoneNoUrl,
        data: emailmemberOtpReqModel.toJson(),
      );
      return response.data["data"];
    } catch (e) {
      return null;
    }
  }

  //Issuer Code Validity
  Future<CheckIssuerCodeResModel?> checkIssuerCode(
      {required String issuerCode, required String countryId}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response =
          await dio.get('$checkIssuer/$countryId?issuerCode=$issuerCode');
      return checkIssuerCodeResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  //Register TopUp first Step
  Future<TopUpStripeResModel?> regTopUpStripe(
      {required RegisterTopUpStripeReqModel
          registerTopUpStripeReqModel}) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.post(topUpIntent,
          data: registerTopUpStripeReqModel.toJson());
      return topUpStripeResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Register TopUp
  Future<RegTopUpResModel?> regTopup(
      {required ConfirmTopUpReqModel regTopUpReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.post(
        stripePayConfirm,
        data: regTopUpReqModel.toJson(),
      );
      return regTopUpResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Sends Phone Otp
  Future<dynamic> createPhoneOtp({required PhoneOtpReq phoneOtpReq}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.post(
        createPhoneOtpUrl,
        data: phoneOtpReq.toJson(),
      );
      return commonResModelFromJson(response.data!);
    } catch (e) {
      if (e is DioException) {
        if (e.response!.statusCode == 409) {
          return e.response!.statusCode;
        } else {
          return jsonDecode(e.response?.data)["message"];
        }
      } else {
        return null;
      }
    }
  }

  //Resend Number OTP
  Future<ResendRegNumberOtpResModel?> resendNumberOTP(
      {required NumberMemberOtpReqModel numberMemberOtpReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      // log(numberMemberOtpReqModel.toJson().toString());
      Response<String> response = await dio.post(
        resendRegNumberOTP,
        data: numberMemberOtpReqModel.toJson(),
      );
      return resendRegNumberOtpResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  //User Registration
  Future<dynamic> userRegister(
      {required RegisterReqModel registerReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      // log(registerReqModel.toJson().toString());
      Response<String> response = await dio.post(
        regMem,
        data: registerReqModel.toJson(),
      );
      // log(response.data!);
      return registerResModelFromJson(response.data!);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is String && data.isNotEmpty) {
        try {
          return errorResModelFromJson(data);
        } catch (_) {}
      }
      if (data is Map) {
        return ErrorResModel.fromJson(Map<String, dynamic>.from(data));
      }
      return ErrorResModel(
        status: e.response?.statusCode,
        message: e.message ?? 'Registration could not be completed.',
      );
    } catch (err) {
      return null;
    }
  }

  // send Email OTP
  // Future<dynamic> createEmailOTP(
  //     {required EmailMemberOtpReqModel emailmemberOtpReqModel}) async {
  //   try {
  //     Dio dio = await getClientNoToken();
  //     Response<String> response = await dio.post(
  //       createEmailMemOTP,
  //       data: emailmemberOtpReqModel.toJson(),
  //     );
  //     return commonResModelFromJson(response.data!);
  //   } catch (e) {
  //     if (e is DioError) {
  //       if (e.response!.statusCode == 409) {
  //         return e.response!.statusCode;
  //       } else {
  //         return jsonDecode(e.response?.data)["message"];
  //       }
  //     } else {
  //       return null;
  //     }
  //   }
  // }

  //Resend the email otp
  // Future<CommonResModel?> resendEmailOTP(
  //     {required EmailMemberOtpReqModel emailmemberOtpReqModel}) async {
  //   try {
  //     Dio dio = await getClientNoToken();
  //     log(emailmemberOtpReqModel.toJson().toString());
  //     Response<String> response = await dio.post(
  //       resendRegEmailMemOTP,
  //       data: emailmemberOtpReqModel.toJson(),
  //     );
  //     return commonResModelFromJson(response.data!);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  //Verify Email OTP
  // Future<dynamic> verifyEmailOTP(
  //     {required VerifyEmailOtpReqModel verifyEmailOtpReqModel}) async {
  //   try {
  //     Dio dio = await getClientNoToken();
  //     Response<String> response = await dio.post(
  //       verifyRegEmailOTP,
  //       data: verifyEmailOtpReqModel.toJson(),
  //     );
  //     return verifymemberOtpResModelFromJson(response.data!);
  //   } on DioException catch (e) {
  //     return errorResModelFromJson(e.response?.data);
  //   } catch (err) {
  //     return null;
  //   }
  // }
}
