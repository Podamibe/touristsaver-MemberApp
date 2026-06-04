import 'package:dio/dio.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/mark_fav_req.dart';
import 'package:touristsaver/models/response/common_res.dart';
import 'package:touristsaver/models/response/merchant_get_all_res.dart';

import '../../../constants/pref.dart';
import '../../../constants/pref_key.dart';
import '../../../models/response/nearby_res.dart';

class DioMerchant {
  // Add Favourite Merchants
  Future<dynamic> markFavouriteMerchants(
      {required MarkFavouriteReqModel markFavouriteReqModel}) async {
    try {
      Dio dio = await getClient();
      Response<String> response =
          await dio.post(addFavouriteURL, data: markFavouriteReqModel.toJson());
      return commonResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // Remove Favourite Merchants
  Future<dynamic> removeFavouriteMerchants({required int merchantID}) async {
    try {
      Dio dio = await getClient();
      Response<String> response =
          await dio.delete('$removeFavouriteURL/$merchantID');
      return secondCommonResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // GetAll Favourite Merchants
  Future<dynamic> getAllFavouriteMerchants() async {
    try {
      Dio dio = AppVariables.accessToken != null
          ? await getClient()
          : await getClientNoToken();
      if (AppVariables.latitude != null) {
        dio.options.queryParameters.addAll({
          'latitude': AppVariables.latitude.toString(),
          'longitude': AppVariables.longitude.toString()
        });
      }
      String? countryId = await Pref().readData(key: saveCountryID);
      if (countryId != null) {
        dio.options.queryParameters.addAll({'countryId': countryId});
      }
      Response<String> response = await dio.get(
          '$getAllFavouriteURL?order_by=createdAt&ordering=DESC&fields=merchantName,maxDiscount&lang=${AppVariables.selectedLanguageNow}');
      return merchantGetAllResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // Get merchant markers for showing in Google Maps
  Future<NearByLocationResModel?> getNearbyMerchants(
      {required double latitude,
      required double longitude,
      required double radius}) async {
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
      // log(response.data!);
      return nearByLocationResModelFromPostCallJson(response.data!);
    } catch (e) {
      return null;
    }
  }
}
