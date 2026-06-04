import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/models/response/user_detail_res.dart';

@immutable
abstract class UserProfileState extends Equatable {}

// data loading state
class UserProfileLoadingState extends UserProfileState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class UserProfileLoadedState extends UserProfileState {
  UserProfileLoadedState(this.userProfile);
  final UserProfileResModel userProfile;
  @override
  List<Object?> get props => [userProfile];
}

// data Error state
class UserProfileErrorState extends UserProfileState {
  UserProfileErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
