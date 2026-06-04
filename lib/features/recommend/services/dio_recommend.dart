import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/error_res.dart';
import 'package:touristsaver/models/request/recommend_mer_req.dart';
import 'package:touristsaver/models/response/common_res.dart';
import 'package:touristsaver/models/response/recommend_mer_res.dart';

class DioRecommend {
  Future<dynamic> createRecommedMer(
      {required RecommendMerchantReqModel recommendMerchantReqModel}) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.post(recommendMerURL,
          data: recommendMerchantReqModel.toJson());
      //  log(response.data!);
      return recommendMerchantResModelFromJson(response.data!);
    } on DioException catch (e) {
      return errorResModelFromJson(e.response?.data);
    } catch (err) {
      // print('Error in creating recommend merchant:$err');
      return null;
    }
  }

  Future<dynamic> createMerchantReferral({
    required String merchantName,
    String? reason,
    String? addressText,
    XFile? uploadFile,
  }) async {
    try {
      final Dio dio = await getClient();
      final formData = FormData.fromMap({
        'merchantName': merchantName,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (addressText != null && addressText.trim().isNotEmpty)
          'addressText': addressText.trim(),
        if (uploadFile != null)
          'uploadFile': await MultipartFile.fromFile(
            uploadFile.path,
            filename: uploadFile.name,
          ),
      });

      final Response<String> response = await dio.post(
        merchantReferralCreateURL,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return commonResModelFromJson(response.data!);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is String) {
        return errorResModelFromJson(data);
      }
      if (data is Map<String, dynamic>) {
        return ErrorResModel.fromJson(data);
      }
      return ErrorResModel(message: 'Unable to submit recommendation');
    } catch (err) {
      return null;
    }
  }
}
