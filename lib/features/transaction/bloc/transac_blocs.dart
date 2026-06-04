import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/transaction/bloc/transac_events.dart';
import 'package:touristsaver/features/transaction/bloc/transac_states.dart';
import 'package:touristsaver/features/transaction/services/dio_transaction.dart';

class TransacBloc extends Bloc<TransacEvent, TransacState> {
  final DioTransaction dioTransaction;
  final String latestDate;
  final String previousDate;

  TransacBloc(this.dioTransaction, this.latestDate, this.previousDate)
      : super(TransacLoadingState()) {
    on<TransacEvent>((event, emit) async {
      emit(TransacLoadingState());
      try {
        final transactionRes =
            await dioTransaction.transac(latestDate, previousDate);
        emit(TransacLoadedState(transactionRes!));
      } catch (e) {
        emit(TransacErrorState(e.toString()));
        // print(e.toString());
      }
    });
  }
}
