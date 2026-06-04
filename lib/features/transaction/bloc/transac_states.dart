import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/models/response/transaction_res.dart';

@immutable
abstract class TransacState extends Equatable {}

// data loading state
class TransacLoadingState extends TransacState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class TransacLoadedState extends TransacState {
  TransacLoadedState(this.transacRes);
  final TransactionResModel transacRes;
  @override
  List<Object?> get props => [transacRes];
}

// data error loading state
class TransacErrorState extends TransacState {
  TransacErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
