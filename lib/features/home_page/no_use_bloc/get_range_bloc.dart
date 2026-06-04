// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:touristsaver/features/home_page/no_use_bloc/get_range_events.dart';
// import 'package:touristsaver/features/home_page/no_use_bloc/get_range_states.dart';
// import 'package:touristsaver/features/home_page/services/home_dio.dart';

// class GetRangeBloc extends Bloc<GetRangeEvent, GetRangeState> {
//   final DioHome dioHome;

//   GetRangeBloc(this.dioHome) : super(GetRangeLoadingState()) {
//     on<GetRangeEvent>((event, emit) async {
//       try {
//         final getRangeList = await dioHome.getNearByRange();
//         emit(GetRangeLoadedState(getRangeList!));
//       } catch (e) {
//         emit(GetRangeErrorState(e.toString()));
//         // print(e.toString());
//       }
//     });
//   }
// }
