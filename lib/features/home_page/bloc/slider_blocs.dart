import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/home_page/bloc/slider_events.dart';
import 'package:touristsaver/features/home_page/bloc/slider_states.dart';
import 'package:touristsaver/features/home_page/services/home_dio.dart';

class SliderBloc extends Bloc<SliderEvent, SliderState> {
  final DioHome dioHome;

  SliderBloc(this.dioHome) : super(SliderLoadingState()) {
    on<SliderEvent>((event, emit) async {
      try {
        final sliderList = await dioHome.getSlider();
        emit(SliderLoadedState(sliderList!));
      } catch (e) {
        emit(SliderErrorState(e.toString()));
        // print(e.toString());
      }
    });
  }
}
