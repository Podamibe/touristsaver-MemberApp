// import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/request/nearby_req.dart';
import 'package:touristsaver/models/request/select_charity_req.dart';
import 'package:touristsaver/models/response/get_charity_list_res.dart';
import 'package:touristsaver/models/response/nearby_charity_res.dart';
import 'package:touristsaver/models/response/select_charity_res.dart';

import '../../../models/response/get_all_charities.dart';
import '../../../models/response/get_all_charities_res_model.dart'
    as charity_get_all;
import '../../../models/response/member_selected_charity_res_model.dart';

class DioCharity {
  // Get Charity By Member
  Future<MemberSelectedCharityResModel?> getCharityByMember() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio
          .get('$charityByMember?lang=${AppVariables.selectedLanguageNow}');
      // log(response.data!);
      return memberSelectedCharityResModelFromJson(response.data!);
    } catch (e) {
      // log('Error in selecting the charity: $e');
      return null;
    }
  }

  // Fetching the list of all the charity
  Future<charity_get_all.GetAllCharitiesResModel?> getAllCharitiesDio(
      String countryId) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$charityList?countryId=$countryId&isActive=true&lang=${AppVariables.selectedLanguageNow}');
      //$charityList?limit=200&$whichCall&isActive=true
      // log(response.data!);
      return charity_get_all.getAllCharitiesResModelFromJson(response.data!);
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  // Fetching the list of all the charity
  Future<GetAllCharities?> getAllCharityList(String? charityName) async {
    String countryId = await Pref().readData(key: saveCountryID);
    String charityApi;
    try {
      Dio dio = await getClient();
      if (charityName!.isEmpty) {
        charityApi =
            '$getAllCharitiesForApp?countryId=$countryId&lang=${AppVariables.selectedLanguageNow}';
      } else {
        charityApi =
            '$getAllCharitiesForApp?countryId=$countryId&charityName=$charityName&lang=${AppVariables.selectedLanguageNow}';
      }
      Response<String> response = await dio.get(charityApi);
      //$charityList?limit=200&$whichCall&isActive=true
      // log(response.data!);
      return getAllCharitiesFromJson(response.data!);
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }
  // Future<GetAllCharities?> getAllCharityList() async {
  //   String countryId = await Pref().readData(key: saveCountryID);
  //   try {
  //     Dio dio = await getClient();
  //     Response<String> response = await dio.get(
  //         '$getAllCharity?limit=200&countryId=$countryId&lang=${AppVariables.selectedLanguageNow}');
  //     //$charityList?limit=200&$whichCall&isActive=true
  //     // log(response.data!);
  //     return getAllCharitiesFromJson(response.data!);
  //   } catch (e) {
  //     // log(e.toString());
  //     return null;
  //   }

  // Fetching the list of all the charity
  Future<AllCharityListResModel?> getCharityList(
      {required String stateId}) async {
    String countryId = await Pref().readData(key: saveCountryID);
    String whichCall;
    if (stateId == 'null') {
      whichCall = 'countryId=$countryId';
    } else {
      whichCall = 'stateId=${int.parse(stateId)}';
    }
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(
          '$charityList?limit=200&$whichCall&isActive=true&lang=${AppVariables.selectedLanguageNow}');
      return allCharityListResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Selecting the charity and updating
  Future<SelectCharityResModel?> selectCharity(
      {required SelectCharityReqModel selectCharityReqModel}) async {
    try {
      Dio dio = await getClient();
      // log(selectCharityReqModel.toJson().toString());
      Response<String> response =
          await dio.patch(updateCharity, data: selectCharityReqModel.toJson());
      // log(response.data!);
      return selectCharityResModelFromJson(response.data!);
    } catch (e) {
      // print('Error in selecting the charity: $e');
      return null;
    }
  }

  // Getting Nearby Location charity
  Future<NearByCharityListResModel?> getNearByCharity(
      {required NearByLocationReqModel nearByLocationReqModel}) async {
    try {
      Dio dio = await getClientNoToken();
      // log(nearByLocationReqModel.toJson().toString());
      Response<String> response =
          await dio.post(getNearCharity, data: nearByLocationReqModel);
      // log(response.data!);
      return nearByCharityListResModelFromJson(response.data!);
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }
}
