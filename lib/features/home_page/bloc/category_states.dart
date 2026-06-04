import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:touristsaver/models/response/category_list_res.dart';

@immutable
abstract class CategoryState extends Equatable {}

// data loading state
class CategoryLoadingState extends CategoryState {
  @override
  List<Object?> get props => [];
}

// data loaded state
class CategoryLoadedState extends CategoryState {
  CategoryLoadedState(this.categoryList);
  final CategoryListResModel categoryList;

  @override
  List<Object?> get props => [categoryList];
}

// data error state
class CategoryErrorState extends CategoryState {
  CategoryErrorState(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}
