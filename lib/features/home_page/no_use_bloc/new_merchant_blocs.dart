// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:touristsaver/features/home_page/no_use_bloc/new_merchant_events.dart';
// import 'package:touristsaver/features/home_page/no_use_bloc/new_merchant_states.dart';
// import 'package:touristsaver/features/home_page/services/home_dio.dart';

// class NewMerchantBloc extends Bloc<NewMerchantEvent, NewMerchantState> {
//   final DioHome dioHome;
//   final int pageNumber;

//   NewMerchantBloc(this.dioHome, this.pageNumber)
//       : super(NewMerchantLoadingState()) {
//     on<NewMerchantEvent>((event, emit) async {
//       try {
//         final newMerchantList =
//             await dioHome.getNewMerchant(pageNumber: pageNumber);
//         emit(NewMerchantLoadedState(newMerchantList!));
//       } catch (e) {
//         emit(NewMerchantErrorState(e.toString()));
//         // print(e.toString());
//       }
//     });
//   }
// }
