import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/apply_piiink_by_merchant_req.dart';
import 'package:touristsaver/models/request/confirm_piiink_req.dart';
import 'package:touristsaver/models/request/sure_apply_piiink_req.dart';
import 'package:touristsaver/models/response/confirm_piiink_res.dart';
import 'package:touristsaver/models/response/is_pay_enable_res.dart';
import 'package:touristsaver/models/response/sure_apply_piiink_res.dart';

class DioPay {
  // Preview a TouristSaver member discount directly from a merchant profile.
  // This mirrors the QR startApplyPiiink lifecycle and does not create a
  // transaction.
  Future<dynamic> startApplyPiiinkByMerchant({
    required ApplyPiiinkByMerchantReqModel applyPiiinkByMerchantReqModel,
  }) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.post(
        startApplyPiiinkByMerchantURL,
        data: applyPiiinkByMerchantReqModel.toJson(),
      );
      return confirmApplyPiiinkResModelFromJson(response.data!);
    } on DioException catch (e) {
      return _paymentError(e);
    } catch (err) {
      return ErrorResModel(message: err.toString());
    }
  }

  // Apply a TouristSaver member discount directly from a merchant profile.
  // This is the final transaction creation step for merchant-profile claims.
  Future<dynamic> applyPiiinkByMerchant({
    required ApplyPiiinkByMerchantReqModel applyPiiinkByMerchantReqModel,
  }) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.post(
        applyPiiinkByMerchantURL,
        data: applyPiiinkByMerchantReqModel.toJson(),
      );
      return confirmApplyPiiinkResModelFromJson(response.data!);
    } on DioException catch (e) {
      return _paymentError(e);
    } catch (err) {
      return ErrorResModel(message: err.toString());
    }
  }

  ErrorResModel _paymentError(DioException e) {
    final responseData = e.response?.data;
    if (responseData is String) {
      try {
        return errorResModelFromJson(
          responseData,
          httpStatusCode: e.response?.statusCode,
        );
      } catch (_) {
        return ErrorResModel(
          status: e.response?.statusCode,
          message: responseData,
          httpStatusCode: e.response?.statusCode,
        );
      }
    }

    if (responseData is Map<String, dynamic>) {
      return ErrorResModel.fromJson(
        responseData,
        httpStatusCode: e.response?.statusCode,
      );
    }

    if (responseData is Map) {
      return ErrorResModel.fromJson(
        jsonDecode(jsonEncode(responseData)) as Map<String, dynamic>,
        httpStatusCode: e.response?.statusCode,
      );
    }

    return ErrorResModel(
      status: e.response?.statusCode,
      message: e.message,
      httpStatusCode: e.response?.statusCode,
    );
  }

  // Confirm the Payment to apply piiink
  Future<dynamic> confirmApplyPiiink(
      {required ConfirmApplyPiiinkReqModel confirmApplyPiiinkReqModel}) async {
    try {
      Dio dio = await getClient();
      // log(confirmApplyPiiinkReqModel.toJson().toString());
      Response<String> response = await dio.post(
        confirmApplyPiiinkURL,
        data: confirmApplyPiiinkReqModel.toJson(),
      );
      // log(response.data!);
      return confirmApplyPiiinkResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      // print("Error in confirmimg the payment: $err");
      return null;
    }
  }

  // Confirm the Payment to apply piiink
  Future<dynamic> confirmTerminalApplyPiiink(
      {required String transactionQrCode}) async {
    try {
      Dio dio = await getClient();
      // log(transactionQrCode);
      Response<String> response = await dio.post(
        terminalConfirmApplyPiiinkURL,
        data: {
          "transactionQRCode": transactionQrCode,
          "lang": AppVariables.selectedLanguageNow
        },
      );
      // log(';;;;;;;;;;;;;;;;;;;;;${response.data}');
      return confirmApplyPiiinkResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // Sure the Payment to apply piiink with the same response
  Future<dynamic> sureApplyPiiink(
      {required bool payToMainMerchant,
      required SureApplyPiiinkReqModel sureApplyPiiinkReqModel}) async {
    final payload = payToMainMerchant
        ? sureApplyPiiinkReqModel.toJsonMainMerchant()
        : sureApplyPiiinkReqModel.toJsonTerminalMerchant();
    try {
      Dio dio = await getClient();
      log('POST $surApplyPiiink payload: $payload');
      Response<String> response = await dio.post(
        surApplyPiiink,
        data: payload,
      );
      log('POST $surApplyPiiink response: ${response.data}');
      return sureApplyPiiinkResModelFromJson(response.data!);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      log('POST $surApplyPiiink failed with status '
          '${e.response?.statusCode}. Payload: $payload. Response: '
          '$responseData');

      if (responseData is String) {
        try {
          return errorResModelFromJson(responseData);
        } catch (_) {
          return ErrorResModel(
            status: e.response?.statusCode,
            message: responseData,
          );
        }
      }

      if (responseData is Map<String, dynamic>) {
        return ErrorResModel.fromJson(responseData);
      }

      if (responseData is Map) {
        return ErrorResModel.fromJson(
          jsonDecode(jsonEncode(responseData)) as Map<String, dynamic>,
        );
      }

      return ErrorResModel(
        status: e.response?.statusCode,
        message: e.message,
      );
    } catch (e) {
      log('POST $surApplyPiiink failed before response. Payload: $payload. '
          'Error: $e');
      return ErrorResModel(message: e.toString());
    }
  }

  // to check the pay enabled or not
  Future<IsPayEnableResModel?> payEnabled() async {
    String? countryId = await Pref().readData(key: saveCountryID);
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(
        '$isPay$countryId',
      );
      return isPayEnableResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }
}
