import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:touristsaver/models/response/get_charity_list_res.dart';

@immutable
abstract class AllCharityState extends Equatable {}

// data loading state
class AllCharityLoadingState extends AllCharityState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class AllCharityLoadedState extends AllCharityState {
  AllCharityLoadedState(this.allCharityList);
  final AllCharityListResModel allCharityList;

  @override
  List<Object?> get props => [allCharityList];
}

// data error loading state
class AllCharityListErrorState extends AllCharityState {
  AllCharityListErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
