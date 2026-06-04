import 'package:dio/dio.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/url_end_point.dart';

import '../../../models/response/claim_piiinks_res_model.dart';
import '../../../models/response/get_free_piiinks_res_model.dart';
import '../../../models/response/merchant_get_my_wallet.dart';
import '../../../models/response/universal_get_my_wallet.dart';

class DioWallet {
  // Fetching user wallet information (Universal Wallet)
  Future<UniversalGetMyWallet?> getUniverslUserWallet() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(universalGetMyWallet);
      return universalGetMyWalletFromJson(response.data!);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Fetching user wallet information (Merchant Wallet)
  Future<MerchantGetMyWallet?> getMerchantUserWallet({int? pageNumber}) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(pageNumber == null
          ? merchantGetMyWallet
          : '$merchantGetMyWallet?page=$pageNumber&lang=${AppVariables.selectedLanguageNow}');
      return merchantGetMyWalletFromJson(response.data!);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Confirm Piiinks
  Future<ClaimPiiinksResModel?> confirmPiiinks() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.post(claimPiinksUrl, data: {});
      return claimPiiinksResModelFromJson(response.data!);
      // } on DioException catch (e) {
      //   return errorResModelFromJson(e.response?.data);
      // }
    } catch (err) {
      return null;
    }
  }

  // Membership get Free Piiinks
  Future<GetFreePiinksResModel?> getFree() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(membershipGetFreeUrl);
      // log(response.data!);
      return getFreePiinksResModelFromJson(response.data!);
      // } on DioException catch (e) {
      //   return errorResModelFromJson(e.response?.data);
      // }
    } catch (err) {
      return null;
    }
  }
}
