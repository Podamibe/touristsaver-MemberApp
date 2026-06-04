import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:touristsaver/models/response/location_get_all.dart';

import '../../../models/response/country_wise_prefix_res_model.dart';

@immutable
abstract class LocationAllState extends Equatable {}

// data loading state
class LocationAllLoadingState extends LocationAllState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class LocationAllLoadedState extends LocationAllState {
  LocationAllLoadedState(this.locationGetAll, this.countryWisePrefixResModel);
  final LocationGetAllResModel locationGetAll;
  final CountryWisePrefixResModel countryWisePrefixResModel;
  @override
  List<Object?> get props => [locationGetAll];
}

// data error loading state
class LocationAllErrorState extends LocationAllState {
  LocationAllErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
