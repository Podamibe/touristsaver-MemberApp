import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:touristsaver/models/response/state_get_all.dart';

@immutable
abstract class StateAllState extends Equatable {}

// data loading state
class StateAllLoadingState extends StateAllState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class StateAllLoadedState extends StateAllState {
  StateAllLoadedState(this.stateGetAll);
  final StateGetAllResModel stateGetAll;
  @override
  List<Object?> get props => [stateGetAll];
}

// data error loading state
class StateAllErrorState extends StateAllState {
  StateAllErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
