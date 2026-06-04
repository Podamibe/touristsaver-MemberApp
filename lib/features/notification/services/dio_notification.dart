import 'package:dio/dio.dart';
import 'package:touristsaver/common/utils.dart';
import 'package:touristsaver/constants/url_end_point.dart';

import '../../../constants/helper.dart';
import '../../../models/error_res.dart';
import '../../../models/response/common_res.dart';
import '../../../models/response/notification_model.dart';

class DioNotification {
  // Gets all notifications
  Future<dynamic> getAllNotifications(String lastThreeMonthsRange) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(
          '$getAllMemberNotifications/?createdAt__between=$lastThreeMonthsRange');
      return notificationModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      //print('Error in fetching notifications:$err');
      return null;
    }
  }

  // Deletes single notification
  Future<dynamic> deleteSingleNotification(int id) async {
    try {
      Dio dio = await getClient();
      String url = deleteMemberSingleNotification.format(params: [id]);
      Response<String> response = await dio.delete(url);
      return commonResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }

  // Deletes all notifications
  Future<dynamic> deleteAllNotifications() async {
    try {
      Dio dio = await getClient();
      Response<String> response =
          await dio.delete(deleteMemberAllNotifications);
      return commonResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      return null;
    }
  }
}
