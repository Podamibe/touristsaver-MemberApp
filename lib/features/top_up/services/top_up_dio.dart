import 'package:dio/dio.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/request/confirm_topup_req.dart';
import 'package:touristsaver/models/request/pre_topup_stripe_req.dart';
import 'package:touristsaver/models/request/premium_topup_req.dart';
import 'package:touristsaver/models/request/top_up_stripe_req.dart';
import 'package:touristsaver/models/response/confirm_topup_res.dart';
import 'package:touristsaver/models/response/member_package_res.dart';
import 'package:touristsaver/models/response/pre_topup_free_res.dart';
import 'package:touristsaver/models/response/pre_topup_paid_res.dart';
import 'package:touristsaver/models/response/premium_validity_res.dart';
import 'package:touristsaver/models/response/top_up_stripe_res.dart';

import '../../../models/response/membership_package_get_one_for_tourist.dart';
import '../../../models/response/membership_package_get_one_by_member_free.dart';
import '../../../models/response/top_up_res.dart';

class DioTopUpStripe {
  //Transaction
  Future<TopUpHistoryResModel?> topUpHist(
      String latestDate, String previousDate) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(
          '$topUpHistory?transactionDate__between=$previousDate:$latestDate&order_by=transactionDate');
      // log(response.data!);
      return topUpHistoryResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // TopUp Stripe
  Future<TopUpStripeResModel?> topUpStripe(
      {required TopUpStripeReqModel topUpStripeReqModel}) async {
    try {
      Dio dio = await getClient();
      // log(topUpStripeReqModel.toJson().toString());
      Response<String> response =
          await dio.post(topUpIntent, data: topUpStripeReqModel.toJson());
      // log(response.data!);
      return topUpStripeResModelFromJson(response.data!);
    } catch (e) {
      // log("Error in TopUp process: $e");
      return null;
    }
  }

  // Confirming the top Up
  Future<ConfirmTopUpResModel?> confirmTopUp(
      {required ConfirmTopUpReqModel confirmTopUpReqModel}) async {
    try {
      Dio dio = await getClient();
      Response<String> response =
          await dio.post(stripePayConfirm, data: confirmTopUpReqModel.toJson());
      // await dio.post('https://sweta.yunik.com.np$stripePayConfirm',
      //     data: confirmTopUpReqModel.toJson());
      // print(response.data);
      return confirmTopUpResModelFromJson(response.data!);
    } catch (e) {
      // print('Error in confirming the topup:$e');
      return null;
    }
  }

  // MemberShip Packages
  Future<MemberShipPackageResModel?> memPack() async {
    String countryId = await Pref().readData(key: saveCountryID);
    try {
      Dio dio = await getClient();
      Response<String> response =
          await dio.get('$memPackageForMember?countryId=$countryId');
      // .get('$memPackage?subscriptionType=premium&countryId=$countryId');
      // log('memPack country ${response.data!}');
      return memberShipPackageResModelFromJson(response.data!);
    } catch (e) {
      // print('Error in showing the membership');
      return null;
    }
  }

  // MemberShip Package For Tourist By Member
  Future<MembershipGetOneForTouristByMember?> memPackForSingle() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(singleMemPackageForMember);
      // log('Tourists ${response.data!}');
      return membershipGetOneForTouristByMemberFromJson(response.data!);
    } catch (e) {
      // print('Error in showing the membership');
      return null;
    }
  }

  // MemberShip Free Package new Free API
  Future<MembershipGetOneForFreeByMember?> memberPackFree() async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.get(memPackageFree);
      // log('Freee ${response.data!}');
      return membershipGetOneForFreeByMemberFromJson(response.data!);
    } catch (e) {
      // print('Error in showing the membership');
      return null;
    }
  }

  //Top Up Premium Validity
  Future<PremiumValidityResModel?> premiumTopupValidity(
      {required PremiumTopUpReqModel premiumTopUpReqModel}) async {
    try {
      Dio dio = await getClient();
      Response<String> response = await dio.post(
        premiumTopupCodeValidity,
        data: premiumTopUpReqModel.toJson(),
      );
      // log(response.data!);
      return premiumValidityResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  //Premium Code Apply
  Future<dynamic> checkPremiumCodeTopUp(
      {required PremiumTopUpReqModel premiumTopUpReqModel}) async {
    try {
      final Dio dio = await getClient();
      Response<String> response = await dio.post(topUpCheckPremiumCode,
          data: premiumTopUpReqModel.toJson());
      // log(response.data!);
      var secondRes = premiumTopUpFreeResModelFromJson(response.data!);
      if (secondRes.data!.premiumCodeIsPaid == false) {
        // log(response.data!);
        return premiumTopUpFreeResModelFromJson(response.data!);
      } else {
        // log(response.data!);
        return premiumTopUpPaidResModelFromJson(response.data!);
      }
    } catch (e) {
      return null;
    }
  }

  // Premium TopUp Stripe
  Future<TopUpStripeResModel?> premiumTopUpStripe(
      {required PremiumTopUpStripeReqModel premiumTopUpStripeReqModel}) async {
    try {
      Dio dio = await getClient();
      // print(premiumTopUpStripeReqModel.toJson());
      Response<String> response = await dio.post(topUpIntent,
          data: premiumTopUpStripeReqModel.toJson());
      // print(response.data);
      return topUpStripeResModelFromJson(response.data!);
    } catch (e) {
      // print("Error in Premium TopUp process: $e");
      return null;
    }
  }
}
