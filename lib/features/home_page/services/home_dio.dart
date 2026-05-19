import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/constants/helper.dart';
import 'package:new_piiink/constants/pref.dart';
import 'package:new_piiink/constants/pref_key.dart';
import 'package:new_piiink/constants/url_end_point.dart';
import 'package:new_piiink/models/request/nearby_req.dart';
import 'package:new_piiink/models/response/category_list_res.dart';
import 'package:new_piiink/models/response/get_range_res.dart';
import 'package:new_piiink/models/response/location_merchants_res_model.dart';
import 'package:new_piiink/models/response/merchant_get_all_res.dart';
import 'package:new_piiink/models/response/nearby_res.dart';
import 'package:new_piiink/models/response/search_merchant_res.dart';
import 'package:new_piiink/models/response/slider_res.dart';
import 'package:new_piiink/models/response/sub_category_list_res.dart';

import '../../../models/response/get_nearby_merchants_res_model.dart';
import '../../../models/response/cat_model.dart';

class DioHome {
  //App Slider
//App Slider
  Future<SliderResModel?> getSlider() async {
    try {
      // 1. Try to read the Country ID
      String? countryID;
      try {
        countryID = await Pref().readData(key: userChosenLocationID);
      } catch (e) {
        debugPrint("Error reading country ID for slider: $e");
      }

      // 2. THE FIX: If the user is logged out, the ID will be null.
      // We must provide a default fallback (e.g., '3' for Australia) so the API doesn't fail.
      if (countryID == null ||
          countryID.isEmpty ||
          countryID == 'null' ||
          countryID == '0') {
        countryID =
            '3'; // <-- Change this to your actual default Country ID if it is not 3
      }

      // 3. Make the API Call safely
      Dio dio = await getClientNoToken();
      Response<String> response = await dio
          .get('$appSlide?countryId=$countryID&order_by=order&ordering=ASC');

      return sliderResModelFromJson(response.data!);
    } catch (e) {
      debugPrint('Error in getting app slider: $e');
      return null;
    }
  }

  // Nearby merchants by location
  Future<dynamic> getOffers(
      {required NearByLocationReqModel nearByLocationReqModel}) async {
    try {
      Dio dio = AppVariables.accessToken != null
          ? await getClient()
          : await getClientNoToken();
      Response<String> response =
          await dio.get(nearByLocation, queryParameters: {
        "limit": 10,
        "ordering": "ASC",
        "latitude": nearByLocationReqModel.latitude,
        "longitude": nearByLocationReqModel.longitude,
        "countryShortName": nearByLocationReqModel.countryCode,
        "lang": AppVariables.selectedLanguageNow,
      });
      return nearByLocationResModelFromJson(response.data!);
    } catch (e) {
      return;
    }
  }

  // Nearby merchants by location Range Selected in viewAllPage
  Future<GetNearByMerchantsResModel?> getNearbyOffers(
      {double? latitude, double? longitude, double? radius}) async {
    try {
      Dio dio = AppVariables.accessToken != null
          ? await getClient()
          : await getClientNoToken();
      Response<String> response = await dio.post(nearByLocation, data: {
        "latitude": latitude,
        "longitude": longitude,
        "radius": radius,
        "lang": AppVariables.selectedLanguageNow
      });
      return getNearByMerchantsResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getBanner(
      {double? latitude, double? longitude, double? radius}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.post(bannerList);
      return (response.data!);
    } catch (e) {
      return null;
    }
  }

  // Popular Offers By Locations
  Future<dynamic> getBestOffers(
      {required NearByLocationReqModel nearByLocationReqModel,
      int? limit}) async {
    try {
      final String? selectedCountryId =
          await Pref().readData(key: userChosenLocationID);
      final String? countryId = selectedCountryId == null ||
              selectedCountryId.isEmpty ||
              selectedCountryId == 'null' ||
              selectedCountryId == '0'
          ? nearByLocationReqModel.countryId?.toString()
          : selectedCountryId;
      Dio dio = AppVariables.accessToken != null
          ? await getClient()
          : await getClientNoToken();
      final Map<String, dynamic> queryParameters = {
        "limit": limit ?? 15,
        "ordering": "DESC",
        "order_by": "maxDiscount",
        "page": nearByLocationReqModel.page,
        "latitude": nearByLocationReqModel.latitude,
        "longitude": nearByLocationReqModel.longitude,
        "radiusKm": 50,
        "countryShortName": nearByLocationReqModel.countryCode,
        "lang": AppVariables.selectedLanguageNow,
      };
      if (countryId != null && countryId.isNotEmpty) {
        queryParameters["countryId"] = countryId;
      }
      Response<String> response =
          await dio.get(nearByLocation, queryParameters: queryParameters);
      // log(response.data!);
      return nearByLocationResModelFromJson(response.data!);
    } catch (e) {
      return;
    }
  }

  // Popular Offers By Locations
  Future<dynamic> getPopularOffers(
      {required NearByLocationReqModel nearByLocationReqModel,
      int? limit}) async {
    try {
      Dio dio = AppVariables.accessToken != null
          ? await getClient()
          : await getClientNoToken();
      Response<String> response =
          await dio.get(nearByLocation, queryParameters: {
        "limit": limit ?? 15,
        "ordering": "ASC",
        "order_by": "popularOrder",
        "isPopularFlag": true,
        "page": nearByLocationReqModel.page,
        "latitude": nearByLocationReqModel.latitude,
        "longitude": nearByLocationReqModel.longitude,
        "countryShortName": nearByLocationReqModel.countryCode,
        "lang": AppVariables.selectedLanguageNow
      });
      return nearByLocationResModelFromJson(response.data!);
    } catch (e) {
      return;
    }
  }

  //NearBy Location Range
  Future<GetNearByRangeResModel?> getNearByRange() async {
    String? countryId = await Pref().readData(key: userChosenLocationID);
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$locationRange?countryId=$countryId&order_by=distanceRange&ordering=ASC');
      // log(response.data!);
      return getNearByRangeResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Category List
  Future<CategoryListResModel?> getCategory(lang) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$categoryList?isVisibleOnApp=true&order_by=priorityOrder&ordering=ASC&limit=100&lang=${AppVariables.selectedLanguageNow}');
      return categoryListResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Member Category List
  Future<MemberCategoryResModel?> getMemberCategory() async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$getAllMemberCategoriesUrl?order_by=priorityOrder&ordering=ASC&limit=100&lang=${AppVariables.selectedLanguageNow}');
      //&lang=${AppVariables.selectedLanguageNow}
      return memberCategoryResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Get Location Merchants
  Future<LocationMerchantsResModel?> getLocationMerchants(
      {String? location, int? categoryId}) async {
    String? countryId = await Pref().readData(key: userChosenLocationID);
    String locationUr = '';
    if (location == '') {
      locationUr = 'categoryId=$categoryId&countryId=$countryId';
    } else if (categoryId == null) {
      locationUr = 'locationName=$location&countryId=$countryId';
    } else {
      locationUr =
          'locationName=$location&categoryId=$categoryId&countryId=$countryId';
    }
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$locationMerchantUrl?$locationUr&lang=${AppVariables.selectedLanguageNow}');
      // log(response.data!);
      return locationMerchantsResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // // Category List by parentID
  // Future<CategoryByParentId?> getCategoryByParentId(String? parentID) async {
  //   try {
  //     Dio dio = await getClient();
  //     int pId = int.parse(parentID!);
  //     Response<String> response = await dio.get('$categorylistByParentID/$pId');
  //     return categoryByParentIdFromJson(response.data!);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // SubCategory List
  Future<SubCategoryListResModel?> getSubCategory(int parentId) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$subCategoryList?parentId=$parentId&order_by=priorityOrder&ordering=ASC&lang=${AppVariables.selectedLanguageNow}');
      // print(response.data);
      return subCategoryListResModelFromJson(response.data!);
    } catch (e) {
      debugPrint('getSubCategory failed for parentId=$parentId: $e');
      return null;
    }
  }

  // Get All Merchant for category and sub category by location
  Future<MerchantGetAllResModel?> getAllMerchant(
      {required int pageNumber, required int categoryId}) async {
    String? countryId = await Pref().readData(key: userChosenLocationID);
    String? stateId =
        await Pref().readData(key: userChosenLocationStateID) == 'null' ||
                await Pref().readData(key: userChosenLocationStateID) == '0' ||
                await Pref().readData(key: userChosenLocationStateID) == null
            ? '0'
            : await Pref().readData(key: userChosenLocationStateID);
    String? regionId =
        await Pref().readData(key: userChosenLocationRegionID) == 'null' ||
                await Pref().readData(key: userChosenLocationRegionID) == '0' ||
                await Pref().readData(key: userChosenLocationRegionID) == null
            ? '0'
            : await Pref().readData(key: userChosenLocationRegionID);
    String enterLocationId;

    if (countryId != '0' && stateId == '0' && regionId == '0') {
      //only entering country ID
      enterLocationId = 'countryId=$countryId';
    } else if (countryId != '0' && stateId != '0' && regionId == '0') {
      enterLocationId = 'countryId=$countryId&stateId=$stateId';
    } else {
      enterLocationId =
          'countryId=$countryId&stateId=$stateId&regionId=$regionId';
    }
    try {
      Dio dio = AppVariables.accessToken != null
          ? await getClient()
          : await getClientNoToken();
      Response<String> response = await dio.get(
          '$allMerchant?category=$categoryId&$enterLocationId&page=$pageNumber&order_by=popularOrder&ordering=ASC&fields=merchantName,maxDiscount,latlon&lang=${AppVariables.selectedLanguageNow}');
      return merchantGetAllResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Get All Merchant for popular merchant by location
  Future<MerchantGetAllResModel?> getPopularMerchant(
      {required int pageNumber}) async {
    String? countryId = await Pref().readData(key: userChosenLocationID);

    String? stateId =
        await Pref().readData(key: userChosenLocationStateID) == 'null' ||
                await Pref().readData(key: userChosenLocationStateID) == '0' ||
                await Pref().readData(key: userChosenLocationStateID) == null
            ? '0'
            : await Pref().readData(key: userChosenLocationStateID);

    String? regionId =
        await Pref().readData(key: userChosenLocationRegionID) == 'null' ||
                await Pref().readData(key: userChosenLocationRegionID) == '0' ||
                await Pref().readData(key: userChosenLocationRegionID) == null
            ? '0'
            : await Pref().readData(key: userChosenLocationRegionID);
    String enterLocationId;

    if (countryId != '0' && stateId == '0' && regionId == '0') {
      enterLocationId = 'countryId=$countryId';
    } else if (countryId != '0' && stateId != '0' && regionId == '0') {
      enterLocationId = 'countryId=$countryId&stateId=$stateId';
    } else {
      enterLocationId =
          'countryId=$countryId&stateId=$stateId&regionId=$regionId';
    }

    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$allMerchant?$enterLocationId&page=$pageNumber&isPopularFlag=true&order_by=popularOrder&ordering=ASC&limit=10&fields=merchantName,maxDiscount&lang=${AppVariables.selectedLanguageNow}');

      return merchantGetAllResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Get All Merchant for new merchant by location
  Future<MerchantGetAllResModel?> getNewMerchant(
      {required int pageNumber, String? name}) async {
    String? countryId = await Pref().readData(key: userChosenLocationID);
    String? stateId =
        await Pref().readData(key: userChosenLocationStateID) == 'null' ||
                await Pref().readData(key: userChosenLocationStateID) == null
            ? '0'
            : await Pref().readData(key: userChosenLocationStateID);
    String? regionId =
        await Pref().readData(key: userChosenLocationRegionID) == 'null' ||
                await Pref().readData(key: userChosenLocationRegionID) == null
            ? '0'
            : await Pref().readData(key: userChosenLocationRegionID);
    String enterLocationId;

    if (countryId != '0' &&
        countryId != 'null' &&
        stateId == '0' &&
        regionId == '0') {
      enterLocationId = 'countryId=$countryId';
    } else if (countryId != '0' &&
        countryId != 'null' &&
        stateId != '0' &&
        regionId == '0') {
      enterLocationId = 'countryId=$countryId&stateId=$stateId';
    } else {
      enterLocationId =
          'countryId=$countryId&stateId=$stateId&regionId=$regionId';
    }
    try {
      Dio dio = AppVariables.accessToken == null
          ? await getClientNoToken()
          : await getClient();

      Response<String> response;

      if (name == 'null' || name == null) {
        response = await dio.get(
            '$allMerchant?$enterLocationId&page=$pageNumber&order_by=verifiedDate&ordering=DESC&limit=10&fields=merchantName,maxDiscount,latlon&lang=${AppVariables.selectedLanguageNow}');
      } else {
        response = await dio.get(
            '$allMerchant?$enterLocationId&page=$pageNumber&merchantName__substring=$name&order_by=verifiedDate&ordering=DESC&limit=10&fields=merchantName,maxDiscount,latlon&lang=${AppVariables.selectedLanguageNow}');
      }

      // 2. Parse the data
      MerchantGetAllResModel parsedData =
          merchantGetAllResModelFromJson(response.data!);

      // 3. Return the parsed data
      return parsedData;
    } catch (e) {
      debugPrint("Error fetching merchants: $e");
      return null;
    }
  }

  // Get All Merchant for best merchant by location
  Future<MerchantGetAllResModel?> getBestMerchant(
      {required int pageNumber}) async {
    String? countryId = await Pref().readData(key: userChosenLocationID);
    String? stateId =
        await Pref().readData(key: userChosenLocationStateID) == 'null' ||
                await Pref().readData(key: userChosenLocationStateID) == '0' ||
                await Pref().readData(key: userChosenLocationStateID) == null
            ? '0'
            : await Pref().readData(key: userChosenLocationStateID);
    String? regionId =
        await Pref().readData(key: userChosenLocationRegionID) == 'null' ||
                await Pref().readData(key: userChosenLocationRegionID) == '0' ||
                await Pref().readData(key: userChosenLocationRegionID) == null
            ? '0'
            : await Pref().readData(key: userChosenLocationRegionID);
    String enterLocationId;
    if (countryId != '0' && stateId == '0' && regionId == '0') {
      //only entering country ID
      enterLocationId = 'countryId=$countryId';
    } else if (countryId != '0' && stateId != '0' && regionId == '0') {
      enterLocationId = 'countryId=$countryId&stateId=$stateId';
    } else {
      enterLocationId =
          'countryId=$countryId&stateId=$stateId&regionId=$regionId';
    }
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$allMerchant?$enterLocationId&page=$pageNumber&order_by=maxDiscount&ordering=DESC&limit=10&fields=merchantName,maxDiscount&lang=${AppVariables.selectedLanguageNow}');

      return merchantGetAllResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Search Merchant
  Future<SearchMerchantResModel?> getSearched(
      {required String name, String? category}) async {
    String? countryId = await Pref().readData(key: userChosenLocationID);
    try {
      Dio dio = AppVariables.accessToken != null
          ? await getClient()
          : await getClientNoToken();
      Response<String> response = await dio.get(
          '$searchMerchant/$name?countryId=$countryId&lang=${AppVariables.selectedLanguageNow}');
      // log(response.data!);
      return searchMerchantResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }
}
