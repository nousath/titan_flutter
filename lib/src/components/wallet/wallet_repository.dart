import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/log_util.dart';

import 'vo/coin_vo.dart';
import 'vo/wallet_vo.dart';

class WalletRepository {
  Future updateWalletVoBalance(WalletVo walletVo, [String symbol, String contractAddress]) {
    return Future.wait(walletVo.coins
        .where((coin) => symbol == null || (coin.symbol == symbol && coin.contractAddress == contractAddress))
        .map((coin) => updateCoinBalance(walletVo.wallet, coin))
        .toList());
  }

  Future updateCoinBalance(Wallet wallet, CoinVo coin) async {
    var balance = BigInt.from(0);
    if (coin.coinType == CoinType.ETHEREUM || coin.coinType == CoinType.HYN_ATLAS) {
      try {
        balance = await wallet.getBalanceByCoinTypeAndAddress(coin.coinType, coin.address, coin.contractAddress);
      } catch (exception) {
        LogUtil.uploadException(exception, 'update Coin Balance!');
      }
    } else if (coin.coinType == CoinType.BITCOIN) {
      balance = await wallet.getBitcoinBalance(wallet.getBitcoinZPub());
    }
    coin.balance = balance;
//    coin.balance = (Decimal.parse(balance.toString()) / Decimal.parse(pow(10, coin.decimals).toString())).toDouble();
  }

  Future<Wallet> getActivatedWalletFormLocalDisk() async {
    var keystoreFileName = await getActivatedWalletFileName();
    if (keystoreFileName != null) {
      return await WalletUtil.loadWallet(keystoreFileName);
    }
    return null;
  }

  ///
  /// save the wallet file name of wallet to local dist
  ///
  Future saveActivatedWalletFileName(String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (fileName == null) {
      await prefs.remove(PrefsKey.ACTIVATED_WALLET_FILE_NAME);
    } else {
      await prefs.setString(PrefsKey.ACTIVATED_WALLET_FILE_NAME, fileName);
    }
  }

  ///
  /// load activated wallet from local dist
  ///
  Future<String> getActivatedWalletFileName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefsKey.ACTIVATED_WALLET_FILE_NAME);
  }
}
