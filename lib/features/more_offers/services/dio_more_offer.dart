import 'package:dio/dio.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/response/get_all_discount.dart';

class DioMoreOffer {
  // Get All Discount Info
  Future<GetAllDiscountResModel?> getAllDiscount(
      {required int merchantId}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get('$discountInfo/$merchantId');
      return getAllDiscountResModelFromJson(response.data!);
    } catch (e) {
      // print('Error in fetching discount info: $e');
      return null;
    }
  }
}
