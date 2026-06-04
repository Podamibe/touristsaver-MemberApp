import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/features/home_page/models/home_feed_post.dart';

class DioHomeFeed {
  Future<List<HomeFeedPost>> getPosts() async {
    try {
      final Dio dio = AppVariables.accessToken != null
          ? await getClient()
          : await getClientNoToken();
      final Response<dynamic> response = await dio.get(homeFeedPosts);
      return HomeFeedPost.listFromResponse(response.data);
    } on DioException catch (e) {
      final int? statusCode = e.response?.statusCode;
      if (statusCode == 400 || statusCode == 404) {
        debugPrint(
          'Home feed endpoint unavailable during rollout: $statusCode',
        );
        return const [];
      }
      debugPrint('Error fetching home feed posts: $e');
      rethrow;
    }
  }
}
