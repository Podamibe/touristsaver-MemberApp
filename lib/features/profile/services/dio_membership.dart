import 'package:dio/dio.dart';
import 'package:new_piiink/constants/helper.dart';
import 'package:new_piiink/constants/url_end_point.dart';
import 'package:new_piiink/models/request/change_password_req.dart';
import 'package:new_piiink/models/response/change_password_res.dart';
import 'package:new_piiink/models/response/user_detail_res.dart';

class DioMemberShip {
  // Retrieving the user profile
  Future<UserProfileResModel?> getUserProfile() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(oneMember);
      // log(response.data!);
      return userProfileResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Change Password
  Future<ChangePasswordResModel?> changePass(
      {required ChangePasswordReqModel changePasswordReqModel}) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.post(changePasswordUrl,
          data: changePasswordReqModel.toJson());
      return changePasswordResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }
}
