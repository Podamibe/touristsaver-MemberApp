import 'package:dio/dio.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/response/detail_res.dart';

import 'fav_or_not.dart';

class DioDetail {
  //Calling merchant Detail
  Future<MerchantDetailResModel?> getMerchantDetail(
      {required int id, required String day, required int hour}) async {
    try {
      Dio dio = await getClientNoToken();
      String endpointPath =
          '$merchantDetail/$id?day=$day&hour=$hour&lang=${AppVariables.selectedLanguageNow}';
      Response<String> response = await dio.get(endpointPath);
      return merchantDetailResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  //Calling merchant is favourite or not
  Future<FavOrNot?> getMerchnatFavOrNot({required String? merchantId}) async {
    try {
      Dio dio = await getClient();
      Response<String> response =
          await dio.get('$merchantFavOrNot/$merchantId');
      return favOrNotFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }
}
