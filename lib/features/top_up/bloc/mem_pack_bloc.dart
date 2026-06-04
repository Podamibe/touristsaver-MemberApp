import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/top_up/bloc/mem_pack_event.dart';
import 'package:touristsaver/features/top_up/bloc/mem_pack_state.dart';
import 'package:touristsaver/features/top_up/services/top_up_dio.dart';

class MemPackAllBloc extends Bloc<MemPackAllEvent, MemPackAllState> {
  final DioTopUpStripe dioMemPackAll;

  MemPackAllBloc(this.dioMemPackAll) : super(MemPackAllLoadingState()) {
    on<MemPackAllEvent>((event, emit) async {
      emit(MemPackAllLoadingState());
      try {
        final memPackAll = await dioMemPackAll.memPack();
        final memPackAll2 = await dioMemPackAll.memberPackFree();
        final memPackAll3 = await dioMemPackAll.memPackForSingle();
        emit(MemPackAllLoadedState(memPackAll!, memPackAll2!, memPackAll3!));
      } catch (e) {
        emit(MemPackAllErrorState(e.toString()));
        // log(e.toString());
      }
    });
  }
}
