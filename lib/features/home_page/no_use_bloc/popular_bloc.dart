// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:touristsaver/features/home_page/no_use_bloc/popular_events.dart';
// import 'package:touristsaver/features/home_page/no_use_bloc/popular_states.dart';
// import 'package:touristsaver/features/home_page/services/home_dio.dart';

// class PopularMerchantBloc
//     extends Bloc<PopularMerchantEvent, PopularMerchantState> {
//   final DioHome dioHome;
//   final int pageNumber;

//   PopularMerchantBloc(this.dioHome, this.pageNumber)
//       : super(PopularMerchantLoadingState()) {
//     on<PopularMerchantEvent>((event, emit) async {
//       try {
//         final popularMerchantList =
//             await dioHome.getPopularMerchant(pageNumber: pageNumber);
//         emit(PopularMerchantLoadedState(popularMerchantList!));
//       } catch (e) {
//         emit(PopularMerchantErrorState(e.toString()));
//         // print(e.toString());
//       }
//     });
//   }
// }
