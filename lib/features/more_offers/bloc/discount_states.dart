import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:touristsaver/models/response/get_all_discount.dart';

@immutable
abstract class MerchantDiscountState extends Equatable {}

// data loading state
class MerchantDiscountLoadingState extends MerchantDiscountState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class MerchantDiscountLoadedState extends MerchantDiscountState {
  MerchantDiscountLoadedState(this.merchantDiscount);
  final GetAllDiscountResModel merchantDiscount;

  @override
  List<Object?> get props => [merchantDiscount];
}

// data error loading state
class MerchantDiscountErrorState extends MerchantDiscountState {
  MerchantDiscountErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
