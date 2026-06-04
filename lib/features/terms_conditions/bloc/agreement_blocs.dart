import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/terms_conditions/bloc/agreement_events.dart';
import 'package:touristsaver/features/terms_conditions/bloc/agreement_states.dart';
import 'package:touristsaver/features/terms_conditions/services/dio_agreement.dart';

class AgreementBloc extends Bloc<AgreementEvent, AgreementState> {
  final DioAgreement dioAgreement;

  AgreementBloc(this.dioAgreement) : super(AgreementLoadingState()) {
    on<AgreementEvent>((event, emit) async {
      emit(AgreementLoadingState());
      try {
        final allCharityList = await dioAgreement.getAgreement();
        emit(AgreementLoadedState(allCharityList!));
      } catch (e) {
        emit(AgreementErrorState(e.toString()));
        // print(e.toString());
      }
    });
  }
}
