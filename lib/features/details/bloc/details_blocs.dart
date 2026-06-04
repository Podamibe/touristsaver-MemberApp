import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/details/bloc/details_events.dart';
import 'package:touristsaver/features/details/bloc/details_states.dart';
import 'package:touristsaver/features/details/services/dio_detail.dart';

class MerchantDetailBloc
    extends Bloc<MerchantDetailEvent, MerchantDetailState> {
  final DioDetail dioDetail;
  final int merchantId;
  final String merchantDay;
  final int merchantHour;

  MerchantDetailBloc(
      this.dioDetail, this.merchantId, this.merchantDay, this.merchantHour)
      : super(MerchantDetailLoadingState()) {
    on<LoadMerchantDetailEvent>(_loadMerchantDetails);
  }

  _loadMerchantDetails(
      LoadMerchantDetailEvent event, Emitter<MerchantDetailState> emit) async {
    emit(MerchantDetailLoadingState());
    try {
      final merchantDetail = await dioDetail.getMerchantDetail(
          id: merchantId, day: merchantDay, hour: merchantHour);
      emit(MerchantDetailLoadedState(merchantDetail!));
    } catch (e) {
      emit(MerchantDetailErrorState(e.toString()));
    }
  }
}
