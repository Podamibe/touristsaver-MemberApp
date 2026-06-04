import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/profile/bloc/profile_wallet_events.dart';
import 'package:touristsaver/features/profile/bloc/profile_wallet_states.dart';
import 'package:touristsaver/features/wallet/services/dio_wallet.dart';

class ProfileWalletBloc extends Bloc<ProfileWalletEvent, ProfileWalletState> {
  final DioWallet dioWallet;

  ProfileWalletBloc(this.dioWallet) : super(ProfileWalletLoadingState()) {
    on<GetUniversalUserWalletEvent>(_getUniversalUserWallet);
    on<GetMerchantUserWalletEvent>(_getMerchantUserWallet);
  }

  void _getUniversalUserWallet(GetUniversalUserWalletEvent event,
      Emitter<ProfileWalletState> emit) async {
    emit(ProfileWalletLoadingState());
    try {
      final universalWallet = await dioWallet.getUniverslUserWallet();
      emit(ProfileWalletLoadedState(universalWallet: universalWallet!));
    } catch (e) {
      emit(ProfileWalletErrorState(e.toString()));
    }
  }

  void _getMerchantUserWallet(GetMerchantUserWalletEvent event,
      Emitter<ProfileWalletState> emit) async {
    emit(ProfileWalletLoadingState());
    try {
      final merchantWallet = await dioWallet.getMerchantUserWallet();
      emit(ProfileWalletLoadedState(merchantWallet: merchantWallet));
    } catch (e) {
      emit(ProfileWalletErrorState(e.toString()));
    }
  }
}
