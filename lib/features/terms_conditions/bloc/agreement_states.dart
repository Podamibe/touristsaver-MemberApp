import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:touristsaver/models/response/agreement_res.dart';

@immutable
abstract class AgreementState extends Equatable {}

// data loading state
class AgreementLoadingState extends AgreementState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class AgreementLoadedState extends AgreementState {
  AgreementLoadedState(this.agreement);
  final AgreementResModel agreement;

  @override
  List<Object?> get props => [agreement];
}

// data error loading state
class AgreementErrorState extends AgreementState {
  AgreementErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
