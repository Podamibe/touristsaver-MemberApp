import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:new_piiink/constants/helper.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/constants/url_end_point.dart';
import 'package:new_piiink/models/request/ver_num_changed_req.dart';
import 'package:new_piiink/models/response/piiink_info_res.dart';
import 'package:new_piiink/models/response/stripe_key_res.dart';
import 'package:new_piiink/models/response/user_delete_res.dart';
import 'package:new_piiink/models/response/ver_num_changed_res.dart';

import '../../models/response/app_version_log_model.dart';

class DioCommon {
  // Verify Changed Mobile Number
  Future<AppVersionLogModel?> appVersionLog(String? platformType) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
        '$appVersionLogUrl/$platformType',
      );
      return appVersionLogModelFromJson(response.data!);
    } catch (e) {
      // print("Error in updating changed mobile number: $e");
      return null;
    }
  }

  Future<dynamic> getBanner(
      {double? latitude, double? longitude, double? radius}) async {
    try {
      Dio dio = await getClientNoToken();
      // Changed Response<String> to Response<dynamic>
      Response response = await dio.get(bannerList);

      // If Dio hasn't already auto-decoded it, decode it manually
      if (response.data is String) {
        return jsonDecode(response.data);
      }
      return response.data;
    } catch (e) {
      print("DEBUG: Banner API failed with error: $e");
      return null;
    }
  }

  Future<dynamic> getdiscountInmemberPremiumCode() async {
    try {
      Dio dio = await getClient();
      Response response = await dio.get(memberPremiumGetOne);
      if (response.data is String) {
        return jsonDecode(response.data);
      }
      print("DEBUG: Member Premium API response: ${response.data}");

      return response.data;
    } catch (e) {
      print("DEBUG: Banner API failed with error: $e");

      return Future.error(e.toString());
    }
  }

  Future<dynamic> getShowCharity() async {
    try {
      Dio dio = await getClientNoToken();
      Response response = await dio.get(showCharityGetOne);
      if (response.data is String) {
        return jsonDecode(response.data);
      }

      return response.data;
    } catch (e) {
      print("DEBUG: Banner API failed with error: $e");

      return Future.error(e.toString());
    }
  }

  // Verify Changed Mobile Number
  Future<VerifyChangedNumberResModel?> editProfile(
      {required VerifyChangedNumberReqModel
          verifyChangedNumberReqModel}) async {
    try {
      Dio dio = await getClient();
      // log(verifyChangedNumberReqModel.toJson().toString());
      Response<String> response = await dio.put(verifyChangedNum,
          data: verifyChangedNumberReqModel.toJson());
      // log(response.data!);
      return verifyChangedNumberResModelFromJson(response.data!);
    } catch (e) {
      // print("Error in updating changed mobile number: $e");
      return null;
    }
  }

  //Delete User
  Future<UserDeleteResModel?> userDeletion() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.delete(deleteUser);
      return userDeleteResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  //Control for showing piiink content
  Future<PiiinkInfoResModel?> piiinkInfo() async {
    String? countryID = await Pref().readData(key: saveCountryID);
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get('$piiinkInfoURL/$countryID');
      return piiinkInfoResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  //Get Stripe Key after login
  Future<StripeKeyResModel?> getStripe() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(stripeKey);
      return stripeKeyResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  Future<StripeKeyResModel?> getStripeWithCountryID() async {
    try {
      String countryID = await Pref().readData(key: saveCountryID);
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get('$stripeKey/$countryID');
      return stripeKeyResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  //Checking Number with the country
  // Future<bool> checkCounNum(
  //     {required String mobileNum, required String code}) async {
  //   PhoneNumberUtil plugin = PhoneNumberUtil();
  //   try {
  //     bool response = await plugin.validate(mobileNum, regionCode: code);
  //     // print(response);
  //     return response;
  //   } catch (e) {
  //     // print("Error in creating an account: $e");
  //     return false;
  //   }
  // }
}
