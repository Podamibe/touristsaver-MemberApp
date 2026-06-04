import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/models/response/member_package_res.dart';

import '../../../models/response/membership_package_get_one_for_tourist.dart';
import '../../../models/response/membership_package_get_one_by_member_free.dart';

@immutable
abstract class MemPackAllState extends Equatable {}

// data loading state
class MemPackAllLoadingState extends MemPackAllState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class MemPackAllLoadedState extends MemPackAllState {
  MemPackAllLoadedState(this.memPackAll, this.memPackAll2, this.memPackAll3);
  final MemberShipPackageResModel memPackAll;
  final MembershipGetOneForFreeByMember memPackAll2;
  final MembershipGetOneForTouristByMember memPackAll3;
  @override
  List<Object?> get props => [memPackAll, memPackAll2, memPackAll3];
}

// data error loading state
class MemPackAllErrorState extends MemPackAllState {
  MemPackAllErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
