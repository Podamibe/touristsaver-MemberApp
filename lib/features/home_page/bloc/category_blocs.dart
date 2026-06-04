import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/home_page/bloc/category_events.dart';
import 'package:touristsaver/features/home_page/bloc/category_states.dart';
import 'package:touristsaver/features/home_page/services/home_dio.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final DioHome dioHome;

  CategoryBloc(this.dioHome) : super(CategoryLoadingState()) {
    on<LoadCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        final categoryList = await dioHome.getCategory(event.lang);
        emit(CategoryLoadedState(categoryList!));
      } catch (e) {
        emit(CategoryErrorState(e.toString()));
        // print(e.toString());
      }
    });
  }
}
