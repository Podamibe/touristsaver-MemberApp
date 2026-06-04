import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/location/bloc/state_all_events.dart';
import 'package:touristsaver/features/location/bloc/state_all_states.dart';
import 'package:touristsaver/features/location/services/dio_location.dart';

class StateAllBloc extends Bloc<StateAllEvent, StateAllState> {
  final DioLocation dioState;
  final int countryID;

  StateAllBloc(this.dioState, this.countryID) : super(StateAllLoadingState()) {
    on<StateAllEvent>((event, emit) async {
      emit(StateAllLoadingState());
      try {
        final stateGetAll = await dioState.getAllState(countryID: countryID);
        emit(StateAllLoadedState(stateGetAll!));
      } catch (e) {
        emit(StateAllErrorState(e.toString()));
        // print(e.toString());
      }
    });
  }
}
