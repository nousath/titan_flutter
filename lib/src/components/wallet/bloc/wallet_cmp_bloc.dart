import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

import 'bloc.dart';
import '../../../global.dart';
import '../wallet_repository.dart';
import '../vo/wallet_vo.dart';
import '../vo/coin_vo.dart';

class WalletCmpBloc extends Bloc<WalletCmpEvent, WalletCmpState> {
  final WalletRepository walletRepository;

  WalletCmpBloc({@required this.walletRepository});

  WalletVo _activatedWalletVo;

  @override
  WalletCmpState get initialState => InitialWalletCmpState();

  @override
  Stream<WalletCmpState> mapEventToState(WalletCmpEvent event) async* {
    if (event is ActiveWalletEvent) {
      if (event.wallet == null) {
        _activatedWalletVo = null;
      } else {
        _activatedWalletVo = walletToWalletCoinsVo(event.wallet);
      }

      await walletRepository.saveActivatedWalletFileName(_activatedWalletVo?.wallet?.keystore?.fileName);

      yield ActivatedWalletState(walletVo: _activatedWalletVo);
    } else if (event is UpdateActivatedWalletBalanceEvent) {
      if (_activatedWalletVo != null) {
        yield UpdatingWalletBalanceState();

        await walletRepository.updateWalletVoBalance(_activatedWalletVo, event.symbol);

        yield UpdatedWalletBalanceState(walletVo: _activatedWalletVo);
      }
    } else if (event is LoadLocalDiskWalletAndActiveEvent) {
      yield LoadingWalletState();

      try {
        var wallet = await walletRepository.getActivatedWalletFormLocalDisk();
        //now active loaded wallet_vo. tips: maybe null
        add(ActiveWalletEvent(wallet: wallet));
      } catch (e) {
        logger.e(e);

        yield LoadWalletFailState();
      }
    }
  }

  /// flat wallet accounts
  WalletVo walletToWalletCoinsVo(Wallet wallet) {
    List<CoinVo> coins = [];
    for (var account in wallet.accounts) {
      // add public chain coin
      CoinVo coin = CoinVo(
        name: account.token.name,
        symbol: account.token.symbol,
        coinType: account.coinType,
        address: account.address,
        decimals: account.token.decimals,
        logo: account.token.logo,
        contractAddress: null,
        balance: 0,
      );
      coins.add(coin);

      //add contract coin by the chain
      for (var asset in account.contractAssetTokens) {
        CoinVo contractCoin = CoinVo(
          name: asset.name,
          symbol: asset.symbol,
          coinType: account.coinType,
          address: account.address,
          decimals: asset.decimals,
          contractAddress: asset.contractAddress,
          logo: asset.logo,
          balance: 0,
        );
        coins.add(contractCoin);
      }
    }
    return WalletVo(wallet: wallet, coins: coins);
  }
}