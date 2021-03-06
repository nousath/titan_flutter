import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/token.dart';

import 'wallet_const.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final String address;
  final String derivationPath;
  final int coinType;
  final String extendedPublicKey;

  final AssetToken token;
  final List<AssetToken> contractAssetTokens;

  Account({
    this.address,
    this.derivationPath,
    this.coinType,
    this.token,
    this.contractAssetTokens,
    this.extendedPublicKey,
  });

  factory Account.fromJsonWithNet(Map<dynamic, dynamic> json, [EthereumNetType netType = EthereumNetType.main]) {
    AssetToken token;
    var erc20Tokens = <AssetToken>[];
    if (json['coinType'] == CoinType.ETHEREUM) {
      token = SupportedTokens.ETHEREUM;
      //active contract tokens
      if (netType == EthereumNetType.main) {
//        erc20Tokens.add(SupportedTokens.HYN_ERC20);
        erc20Tokens.add(SupportedTokens.USDT_ERC20);
      } else if (netType == EthereumNetType.ropsten) {
//        erc20Tokens.add(SupportedTokens.HYN_ROPSTEN);
        erc20Tokens.add(SupportedTokens.USDT_ERC20_ROPSTEN);
      } else if (netType == EthereumNetType.rinkeby) {
        erc20Tokens.add(SupportedTokens.USDT_ERC20_ROPSTEN);
//        erc20Tokens.add(SupportedTokens.HYN_RINKEBY);
      } else {
        erc20Tokens.add(SupportedTokens.USDT_ERC20_ROPSTEN);
//        erc20Tokens.add(SupportedTokens.HYN_LOCAL);
      }
    } else if (json['coinType'] == CoinType.BITCOIN) {
      token = SupportedTokens.BTC;
    } else if (json['coinType'] == CoinType.HYN_ATLAS){
      token = SupportedTokens.HYN_Atlas;
      if (netType == EthereumNetType.main) {
        erc20Tokens.add(SupportedTokens.HYN_RP_HRC30);
      }else if(netType == EthereumNetType.ropsten){
        erc20Tokens.add(SupportedTokens.HYN_RP_HRC30_ROPSTEN);
      }else{
        erc20Tokens.add(SupportedTokens.HYN_RP_HRC30_LOCAL);
      }
    }
    return Account(
      address: json['address'],
      derivationPath: json['derivationPath'],
      coinType: json['coinType'],
      extendedPublicKey: json['extendedPublicKey'],
      token: token,
      contractAssetTokens: erc20Tokens,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  @override
  String toString() {
    return 'Account{address: $address, derivationPath: $derivationPath, coinType: $coinType, token: $token, contractAssetTokens: $contractAssetTokens}';
  }
}
