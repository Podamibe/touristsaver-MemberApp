import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/features/wallet/bloc/wallet_event.dart';
import 'package:touristsaver/features/wallet/bloc/wallet_state.dart';

import '../services/dio_wallet.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final DioWallet dioWallet;
  // final String latestDate;
  // final String previousDate;

  WalletBloc(this.dioWallet) : super(WalletLoadingState()) {
    on<WalletEvent>((event, emit) async {
      emit(WalletLoadingState());
      try {
        final dioWalletRes = await dioWallet.getUniverslUserWallet();
        emit(WalletLoadedState(dioWalletRes!));
      } catch (e) {
        emit(WalletErrorState(e.toString()));
        // print(e.toString());
      }
    });
  }
}
