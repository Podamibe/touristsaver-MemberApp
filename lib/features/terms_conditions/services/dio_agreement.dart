import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:new_piiink/constants/helper.dart';
import 'package:new_piiink/constants/url_end_point.dart';
import 'package:new_piiink/models/response/agreement_res.dart';

import '../../../constants/pref.dart';
import '../../../constants/pref_key.dart';

class DioAgreement {
  // Getting Terms and Conditions
  Future<AgreementResModel?> getAgreement() async {
    try {
      String? firstChoseCountryId;

      // SAFELY try to read from storage
      try {
        firstChoseCountryId = await Pref().readData(key: saveCountryID) ??
            await Pref().readData(key: userChosenLocationID);
      } catch (e) {
        debugPrint("Error reading country ID on iOS: $e");
      }

      // FALLBACK: If the Apple Reviewer hasn't chosen a country yet, default to Australia (3)
      if (firstChoseCountryId == null ||
          firstChoseCountryId.isEmpty ||
          firstChoseCountryId == 'null') {
        firstChoseCountryId =
            '3'; // Replace 3 with your actual default Country ID
      }

      final Dio dio = await getClientNoToken();
      Response<String> response =
          await dio.get('$agreement/$firstChoseCountryId');
      return agreementResModelFromJson(response.data!);
    } catch (e) {
      debugPrint("API Agreement Error: $e");
      return null;
    }
  }
}
