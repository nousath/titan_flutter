import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/start_join_instance.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

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

  NodeApi _nodeApi = NodeApi();

  int _lastUpdateBalanceTime = 0;

  @override
  Stream<WalletCmpState> mapEventToState(WalletCmpEvent event) async* {
    if (event is ActiveWalletEvent) {
      var isSameWallet = false;

      if (event.wallet == null) {
        _activatedWalletVo = null;
      } else {
        if (_activatedWalletVo?.wallet?.getEthAccount()?.address == event.wallet.getEthAccount().address) {
          isSameWallet = true;
        }
        _activatedWalletVo = walletToWalletCoinsVo(event.wallet);
      }

      if (!isSameWallet) {
        _lastUpdateBalanceTime = 0; //set can update balance in time.
        walletRepository.saveActivatedWalletFileName(_activatedWalletVo?.wallet?.keystore?.fileName);

        _recoverBalanceFromDisk(_activatedWalletVo);

        //sync wallet account to server
        if((event.wallet?.getBitcoinZPub() ?? false) != ""){
          BitcoinApi.syncBitcoinPubToServer(event.wallet?.getBitcoinZPub() ?? "", "P2WPKH");
        }
//        _nodeApi.postWallets(_activatedWalletVo);
      }

      yield ActivatedWalletState(walletVo: _activatedWalletVo?.copyWith());
    } else if (event is UpdateActivatedWalletBalanceEvent) {
      var nowTime = DateTime.now().millisecondsSinceEpoch;
      //30 second cache time
      bool isOutOfCacheTme = nowTime - _lastUpdateBalanceTime > 10 * 1000;
      if (_activatedWalletVo != null && isOutOfCacheTme) {
        _lastUpdateBalanceTime = nowTime;
        yield UpdatingWalletBalanceState();

        try {
          await walletRepository.updateWalletVoBalance(_activatedWalletVo, event.symbol);
          _saveWalletVoBalanceToDisk(_activatedWalletVo); //save balance data to disk;
          yield UpdatedWalletBalanceState(walletVo: _activatedWalletVo.copyWith());
        } catch (e) {
          logger.e(e);

          yield UpdateFailedWalletBalanceState();
        }
      }
    } else if (event is LoadLocalDiskWalletAndActiveEvent) {
      yield LoadingWalletState();

      try {
        var wallet = await walletRepository.getActivatedWalletFormLocalDisk();
        //now active loaded wallet_vo. tips: maybe null
        add(ActiveWalletEvent(wallet: wallet));
//        await Future.delayed(Duration(milliseconds: 100));
//        add(UpdateActivatedWalletBalanceEvent());
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
        extendedPublicKey: account.extendedPublicKey,
        balance: BigInt.from(0),
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
          balance: BigInt.from(0),
        );
        coins.add(contractCoin);
      }
    }
    return WalletVo(wallet: wallet, coins: coins);
  }

  void _saveWalletVoBalanceToDisk(WalletVo vo) {
    List jsonList = List();
    vo.coins.map((item) => jsonList.add(item.toJson())).toList();
    var encoded = json.encode(jsonList);
    AppCache.saveValue(PrefsKey.walletBalance, encoded);
  }

  void _recoverBalanceFromDisk(WalletVo vo) async {
    var encoded = await AppCache.getValue(PrefsKey.walletBalance);
    if (encoded != null && encoded != '') {
      List decoded = json.decode(encoded);
      var deList = decoded.map((item) => CoinVo.fromJson(item)).toList();
      for (var cVo in vo.coins) {
        for (var dVO in deList) {
          if (cVo.symbol == dVO.symbol) {
            cVo.balance = dVO.balance;
            break;
          }
        }
      }
    }
  }
}
