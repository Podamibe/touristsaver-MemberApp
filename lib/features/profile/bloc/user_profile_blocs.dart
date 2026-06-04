import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/profile/bloc/user_profile_events.dart';
import 'package:touristsaver/features/profile/bloc/user_profile_states.dart';
import 'package:touristsaver/features/profile/services/dio_membership.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final DioMemberShip dioUserProfile;

  UserProfileBloc(this.dioUserProfile) : super(UserProfileLoadingState()) {
    on<UserProfileEvent>((event, emit) async {
      emit(UserProfileLoadingState());
      try {
        final userProfile = await dioUserProfile.getUserProfile();
        emit(UserProfileLoadedState(userProfile!));
      } catch (e) {
        emit(UserProfileErrorState(e.toString()));
      }
    });
  }
}
