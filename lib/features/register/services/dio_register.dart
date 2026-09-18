import 'dart:convert';
// import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/common/models/registration_code_resolution.dart';
import 'package:touristsaver/common/models/member_error_presentation.dart';
import 'package:touristsaver/common/models/discovery_membership_context.dart';
import 'package:touristsaver/common/models/registration_credential_check.dart';
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
import 'package:touristsaver/models/response/residence_country_res_model.dart';
import 'package:touristsaver/models/response/top_up_stripe_res.dart';

import '../../../constants/pref.dart';
import '../../../models/request/phone_otp_req.dart';
import '../../../models/response/country_wise_prefix_res_model.dart';
import '../../../models/response/sms_validation_res_model.dart';

class DioRegister {
  DioRegister({Dio? registrationCodeClient, Dio? authenticatedClient})
      : _registrationCodeClient = registrationCodeClient,
        _authenticatedClient = authenticatedClient;

  final Dio? _registrationCodeClient;
  final Dio? _authenticatedClient;

  Future<DiscoveryRegistrationCodeClaimResult> claimDiscoveryRegistrationCode({
    required String code,
  }) async {
    try {
      final Dio dio = _authenticatedClient ?? await getClient();
      final Response<dynamic> response = await dio.post(
        discoveryRegistrationCodeClaim,
        data: {'code': code.trim()},
      );
      final dynamic body = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      final dynamic data = body is Map ? body['data'] : null;
      final dynamic membership =
          data is Map ? data['discoveryMembership'] : null;
      if (membership is Map) {
        return DiscoveryRegistrationCodeClaimResult.success(
          DiscoveryMembershipContext.fromJson(
            Map<String, dynamic>.from(membership),
          ),
        );
      }
      return DiscoveryRegistrationCodeClaimResult.failure(
        MemberErrorPresenter.present(
            context: MemberErrorContext.discoveryClaim),
      );
    } on DioException catch (error) {
      final dynamic body = error.response?.data is String
          ? jsonDecode(error.response?.data as String)
          : error.response?.data;
      final responseError = body is Map
          ? ErrorResModel.fromJson(Map<String, dynamic>.from(body))
          : ErrorResModel();
      return DiscoveryRegistrationCodeClaimResult.failure(
        MemberErrorPresenter.present(
          code: responseError.technicalCode,
          context: MemberErrorContext.discoveryClaim,
          approvedTitle: responseError.memberFacingTitle,
          approvedMessage: responseError.memberFacingMessage,
        ),
      );
    } catch (_) {
      return DiscoveryRegistrationCodeClaimResult.failure(
        MemberErrorPresenter.present(
            context: MemberErrorContext.discoveryClaim),
      );
    }
  }

  Future<RegistrationCodeResolution> resolveRegistrationCode({
    required String code,
    required int countryId,
  }) async {
    try {
      final Dio dio = _registrationCodeClient ?? await getClientNoToken();
      final Response<dynamic> response = await dio.post(
        '/registration-codes/resolve',
        data: {
          'code': code.trim(),
          'countryId': countryId,
        },
      );
      final dynamic body = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (body is Map) {
        return RegistrationCodeResolution.fromJson(
          Map<String, dynamic>.from(body),
        );
      }
      return RegistrationCodeResolution.unavailable();
    } catch (_) {
      return RegistrationCodeResolution.unavailable();
    }
  }

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

  Future<CountryWisePrefixResModel?> countryOptions() async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
        '$publicCountryList?limit=250&order_by=countryName&ordering=ASC',
      );
      return countryWisePrefixResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  Future<ResidenceCountryResModel?> residenceCountries() async {
    try {
      final Dio dio = await getClientNoToken();
      final Response<String> response = await dio.get(residenceCountryList);
      return residenceCountryResModelFromJson(response.data!);
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
  Future<RegistrationCredentialCheckResult?> checkEmailAndPhoneNo(
      {required EmailMemberOtpReqModel emailmemberOtpReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      Response response = await dio.post(
        checkEmailAndPhoneNoUrl,
        data: emailmemberOtpReqModel.toJson(),
      );
      return RegistrationCredentialCheckResult.fromApiData(
        response.data["data"],
      );
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return 409;
      final data = e.response?.data;
      try {
        final body = data is String ? jsonDecode(data) : data;
        if (body is Map) {
          return ErrorResModel.fromJson(Map<String, dynamic>.from(body));
        }
      } catch (_) {}
      return ErrorResModel(httpStatusCode: e.response?.statusCode);
    } catch (_) {
      return ErrorResModel();
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

class DiscoveryRegistrationCodeClaimResult {
  const DiscoveryRegistrationCodeClaimResult._({
    this.membership,
    this.errorPresentation,
  });

  DiscoveryRegistrationCodeClaimResult.failure(MemberErrorPresentation error)
      : this._(errorPresentation: error);

  factory DiscoveryRegistrationCodeClaimResult.success(
    DiscoveryMembershipContext membership,
  ) =>
      DiscoveryRegistrationCodeClaimResult._(membership: membership);

  final DiscoveryMembershipContext? membership;
  final MemberErrorPresentation? errorPresentation;
  String? get errorMessage => errorPresentation?.displayText;

  bool get isSuccess => membership != null;
}
