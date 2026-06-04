import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:touristsaver/models/response/slider_res.dart';

@immutable
abstract class SliderState extends Equatable {}

// data loading state
class SliderLoadingState extends SliderState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class SliderLoadedState extends SliderState {
  SliderLoadedState(this.sliderList);
  final SliderResModel sliderList;

  @override
  List<Object?> get props => [sliderList];
}

// data error state
class SliderErrorState extends SliderState {
  SliderErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
