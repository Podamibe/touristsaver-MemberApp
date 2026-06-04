import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/more_offers/bloc/discount_events.dart';
import 'package:touristsaver/features/more_offers/bloc/discount_states.dart';
import 'package:touristsaver/features/more_offers/services/dio_more_offer.dart';

class MerchantDiscountBloc
    extends Bloc<MerchantDiscountEvent, MerchantDiscountState> {
  final DioMoreOffer dioMoreOffer;
  final int merchantId;

  MerchantDiscountBloc(this.dioMoreOffer, this.merchantId)
      : super(MerchantDiscountLoadingState()) {
    on<MerchantDiscountEvent>((event, emit) async {
      emit(MerchantDiscountLoadingState());
      try {
        final merchantDetail =
            await dioMoreOffer.getAllDiscount(merchantId: merchantId);
        emit(MerchantDiscountLoadedState(merchantDetail!));
      } catch (e) {
        emit(MerchantDiscountErrorState(e.toString()));
        // print(e.toString());
      }
    });
  }
}
