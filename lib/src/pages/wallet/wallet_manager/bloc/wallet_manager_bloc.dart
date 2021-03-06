import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'wallet_manager_event.dart';
import 'wallet_manager_state.dart';

class WalletManagerBloc extends Bloc<WalletManagerEvent, WalletManagerState> {
//  WalletService _walletService;

  WalletManagerBloc() {
//    _walletService = WalletService(context: context);
  }

  @override
  WalletManagerState get initialState => WalletEmptyState();

  @override
  Stream<WalletManagerState> mapEventToState(WalletManagerEvent event) async* {
    if (event is ScanWalletEvent) {
      yield* _scanWallet();
    }
    /*else if (event is SwitchWalletEvent) {
      var walletVo = await _walletService.buildWalletVo(event.wallet);
      BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: event.wallet));

      yield* _switchWallet(event);
    }*/
  }

  Stream<WalletManagerState> _scanWallet() async* {
    var wallets = await WalletUtil.scanWallets();
//    var defaultWalletFileName = await _walletService.getDefaultWalletFileName();
    print("wallets length is ${wallets.length}");
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      yield ShowWalletState(wallets);
    }
  }

//  Stream<WalletManagerState> _switchWallet(SwitchWalletEvent switchWalletEvent) async* {
//    String defaultWalletFileName = switchWalletEvent.wallet.keystore.fileName;
//    await _walletService.saveDefaultWalletFileName(defaultWalletFileName);
//    var wallets = await WalletUtil.scanWallets();
//    print("wallets is ${wallets.length}");
//    if (wallets.length == 0) {
//      yield WalletEmptyState();
//    } else {
//      yield ShowWalletState(wallets, defaultWalletFileName);
//    }
//  }
}
