// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:touristsaver/features/home_page/no_use_bloc/best_offer_events.dart';
// import 'package:touristsaver/features/home_page/no_use_bloc/best_offer_states.dart';
// import 'package:touristsaver/features/home_page/services/home_dio.dart';

// class BestOfferMerchantBloc
//     extends Bloc<BestOfferMerchantEvent, BestOfferMerchantState> {
//   final DioHome dioHome;
//   final int pageNumber;

//   BestOfferMerchantBloc(this.dioHome, this.pageNumber)
//       : super(BestOfferMerchantLoadingState()) {
//     on<BestOfferMerchantEvent>((event, emit) async {
//       try {
//         final bestOfferMerchantList =
//             await dioHome.getBestMerchant(pageNumber: pageNumber);
//         emit(BestOfferMerchantLoadedState(bestOfferMerchantList!));
//       } catch (e) {
//         emit(BestOfferMerchantErrorState(e.toString()));
//         // print(e.toString());
//       }
//     });
//   }
// }
