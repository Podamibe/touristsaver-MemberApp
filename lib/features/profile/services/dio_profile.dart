import 'package:dio/dio.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/change_country_req.dart';
import 'package:touristsaver/models/request/edit_profile_req.dart';
import 'package:touristsaver/models/response/change_country_res.dart';
import 'package:touristsaver/models/response/common_res.dart';
import 'package:touristsaver/models/response/edit_profile_res.dart';

class DioProfile {
  // Edit Profile if number is not edited
  Future<dynamic> editProfile(
      {required EditProfileReqModel editProfileReqModel}) async {
    try {
      Dio dio = await getClient();
      // log(editProfileReqModel.toJson().toString());
      Response<String> response =
          await dio.put(profileEdit, data: editProfileReqModel.toJson());
      return editProfileResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  //delete member
  Future<dynamic> deleteMember() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.put(memberDelete);
      return commonResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // Edit Profile if number is edited
  Future<dynamic> editProfileNumber(
      {required EditProfileReqModelNumber editProfileReqModelnumber}) async {
    try {
      Dio dio = await getClient();
      // log(editProfileReqModelnumber.toJson().toString());
      Response<String> response =
          await dio.put(profileEdit, data: editProfileReqModelnumber.toJson());
      return editProfileResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // Change Country
  Future<dynamic> changeCoun(
      {required ChangeCountryReqModel changeCountryReqModel}) async {
    try {
      Dio dio = await getClient();
      // log(changeCountryReqModel.toJson().toString());
      Response<String> response =
          await dio.put(changeCountryURL, data: changeCountryReqModel.toJson());
      // log(response.data!);
      return changeCountryResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // Verify email
  Future<dynamic> verifyEmail() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.post(verifyEmailUrl, data: {});
      return commonResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }
}
