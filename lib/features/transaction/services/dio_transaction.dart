import 'package:dio/dio.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/response/transaction_res.dart';

import '../../../common/app_variables.dart';

class DioTransaction {
  //Transaction
  Future<TransactionResModel?> transac(
    String previousDate,
    String latestDate,
  ) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(
          '$userTransac?transactionDate__between=$previousDate:$latestDate&order_by=transactionDate&lang=${AppVariables.selectedLanguageNow}');

      // log(response.data!);
      return transactionResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }
}
