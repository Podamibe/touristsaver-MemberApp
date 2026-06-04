import 'package:dio/dio.dart';
import 'package:touristsaver/constants/helper.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/url_end_point.dart';
import 'package:touristsaver/models/response/location_get_all.dart';
import 'package:touristsaver/models/response/postal_code_get_all.dart';
import 'package:touristsaver/models/response/region_get_all.dart';
import 'package:touristsaver/models/response/state_get_all.dart';
import 'package:touristsaver/models/response/state_get_one.dart';

class DioLocation {
  // Get All Location
  Future<LocationGetAllResModel?> getAllLocation() async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$countryList?limit=100&order_by=countryName&ordering=ASC&isActive=true');
      return locationGetAllResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // To get the only country that the user is registered with {This api is used to save the country currency of the user}
  Future<LocationGetAllResModel?> getCurrency() async {
    String countryID = await Pref().readData(key: saveCountryID);
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get('$countryList?id=$countryID');
      return locationGetAllResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Get all the States according to country id
  Future<StateGetAllResModel?> getAllState({required int countryID}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$allState?countryId=$countryID&limit=100&order_by=stateName&ordering=ASC&isActive=true');
      return stateGetAllResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Get all the region according to country id
  Future<RegionGetAllResModel?> getAllRegion(
      {required int stateId, required int countryId}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(
          '$allregion?countryId=$countryId&stateId=$stateId&limit=100&order_by=regionName&ordering=ASC&isActive=true');
      return regionGetAllResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Below this it has not been used anywhere
  // Get one state using state id
  Future<StateGetOneResModel?> getOneState({required int stateID}) async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get('/state/getOne/$stateID');
      return stateGetOneResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  // Get all Postal Code according to country id
  Future<PostalCodeGetAllResModel?> getAllPostalCode() async {
    try {
      Dio dio = await getClientNoToken();
      Response<String> response = await dio.get(allPostalCode);
      return postalCodeGetAllResModelFromJson(response.data!);
    } catch (e) {
      return null;
    }
  }
}
