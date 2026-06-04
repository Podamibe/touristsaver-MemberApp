import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:touristsaver/models/response/detail_res.dart';

@immutable
abstract class MerchantDetailState extends Equatable {}

// data loading state
class MerchantDetailLoadingState extends MerchantDetailState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class MerchantDetailLoadedState extends MerchantDetailState {
  MerchantDetailLoadedState(this.merchantDetail);
  final MerchantDetailResModel merchantDetail;

  @override
  List<Object?> get props => [merchantDetail];
}

// data error loading state
class MerchantDetailErrorState extends MerchantDetailState {
  MerchantDetailErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
