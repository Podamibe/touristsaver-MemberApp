import 'package:dio/dio.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/login_req.dart';
import 'package:touristsaver/models/request/reset_password_req.dart';
import 'package:touristsaver/models/response/login_res.dart';
import '../../../models/response/common_res.dart';
import '../../../models/response/forgot_password_res.dart';

class DioLogin {
  // User Login
  Future<dynamic> userLogin({required LoginReqModel loginReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.post(
        loginMember,
        data: loginReqModel.toJson(),
      );
      // log(response.data!);
      return loginResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // Forgot Password
  Future<ForgotPasswordResModel?> forgotPassword(
      {required int countryId,
      required String phoneNumber,
      required String phoneNumberPrefix,
      String? appSign}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.post(forgotPass, data: {
        "countryId": countryId,
        "phoneNumberPrefix": phoneNumberPrefix,
        "phoneNumber": phoneNumber,
        "appSign": appSign,
      });
      return forgotPasswordResModelFromJson(response.data!);
    } on DioException catch (e) {
      return forgotPasswordResModelFromJson(e.response?.data);
    }
  }

  // Reset Password
  Future<CommonResModel?> resetPassword(
      {required ResetPasswordReqModel resetPasswordReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response =
          await dio.post(resetPass, data: resetPasswordReqModel);
      return commonResModelFromJson(response.data!);
    } on DioException catch (e) {
      return commonResModelFromJson(e.response?.data);
    }
  }
}
