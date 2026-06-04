import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/charity/bloc/all_charity_list_events.dart';
import 'package:touristsaver/features/charity/bloc/all_charity_list_states.dart';
import 'package:touristsaver/features/charity/services/dio_charity.dart';

class AllCharityListBloc extends Bloc<AllCharityListEvent, AllCharityState> {
  final DioCharity dioCharity;
  final String stateId;

  AllCharityListBloc(this.dioCharity, this.stateId)
      : super(AllCharityLoadingState()) {
    on<AllCharityListEvent>((event, emit) async {
      emit(AllCharityLoadingState());
      try {
        final allCharityList =
            await dioCharity.getCharityList(stateId: stateId);
        emit(AllCharityLoadedState(allCharityList!));
      } catch (e) {
        emit(AllCharityListErrorState(e.toString()));
        // print(e.toString());
      }
    });
  }
}
